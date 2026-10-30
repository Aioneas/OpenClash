require 'yaml'
require 'tmpdir'
require 'rbconfig'
require 'open3'

root = File.expand_path('..', __dir__)
overwrite = File.join(root, 'openclash/custom/aioneas_openclash_overwrite.rb')
rules_path = File.join(root, 'openclash/custom/openclash_custom_rules.list')
source = {
  'proxies' => [{'name' => '日本 Example', 'type' => 'ss', 'server' => '127.0.0.1', 'port' => 443, 'cipher' => 'aes-128-gcm', 'password' => 'example-only'}],
  'proxy-providers' => {'sample' => {'type' => 'http', 'url' => 'https://example.com/subscription', 'path' => './proxy_provider/example.yaml'}},
  'dns' => {'enable' => true}, 'ipv6' => false
}
Dir.mktmpdir('openclash-test-') do |dir|
  path = File.join(dir, 'config.yaml')
  File.write(path, YAML.dump(source))
  test_overwrite = File.join(dir, 'overwrite.rb')
  content = File.read(overwrite).sub("'/etc/openclash/custom/openclash_custom_rules.list'", rules_path.inspect)
  raise 'cannot isolate custom rules path' if content == File.read(overwrite)
  File.write(test_overwrite, content)
  stdout, stderr, status = Open3.capture3(RbConfig.ruby, test_overwrite, path)
  raise "overwrite failed: #{stderr}" unless status.success?
  c = YAML.load_file(path)
  raise 'node definitions changed' unless c['proxies'] == source['proxies']
  raise 'subscription definitions changed' unless c['proxy-providers'] == source['proxy-providers']
  raise 'DNS or IPv6 changed' unless c['dns'] == source['dns'] && c['ipv6'] == false
  raise 'unexpected oc-cn-domain provider' if c.fetch('rule-providers').key?('oc-cn-domain')
  groups = c.fetch('proxy-groups').to_h { |g| [g.fetch('name'), g] }
  raise 'some groups lack icons' unless groups.values.all? { |g| g['icon'].to_s.start_with?('https://raw.githubusercontent.com/Aioneas/Surge/main/Icon/') }
  %w[X Grok].each do |name|
    raise "#{name} group missing" unless groups[name] && groups[name]['proxies'] == %w[Proxies HK JP SG TW US]
    provider = c.fetch('rule-providers').fetch(name)
    raise "#{name} provider is invalid" unless provider['type'] == 'http' && provider['behavior'] == 'classical' && provider['url'].end_with?('.clash.yaml')
  end
  rules = YAML.load_file(rules_path).fetch('rules')
  raise 'new rules must precede existing rules' unless rules[0, 2] == ['RULE-SET,Grok,Grok', 'RULE-SET,X,X']
  raise 'final rule changed' unless rules.last == 'MATCH,Final'
  raise 'overwrite did not apply rules' unless c['rules'] == rules
  rules.grep(/^RULE-SET,/).each do |rule|
    _, provider, target = rule.split(',')
    raise "missing provider #{provider}" unless c.fetch('rule-providers').key?(provider)
    raise "missing target #{target}" unless groups.key?(target) || target == 'DIRECT'
  end
  cn_provider = {
    'type' => 'http', 'interval' => 43_200, 'behavior' => 'domain', 'format' => 'mrs',
    'url' => 'https://example.com/cn.mrs', 'path' => './rule_provider/oc-cn-domain.mrs'
  }
  dns_with_cn_filter = {'enable' => true, 'fake-ip-filter' => ['geosite:cn', 'rule-set:oc-cn-domain']}
  with_cn_provider = source.merge(
    'dns' => dns_with_cn_filter,
    'rule-providers' => {'oc-cn-domain' => cn_provider, 'unrelated-old-provider' => {'type' => 'file'}}
  )
  File.write(path, YAML.dump(with_cn_provider))
  2.times do
    _, stderr, status = Open3.capture3(RbConfig.ruby, test_overwrite, path)
    raise "overwrite with OpenClash DNS provider failed: #{stderr}" unless status.success?
    result = YAML.load_file(path)
    raise 'OpenClash DNS filter changed' unless result['dns'] == dns_with_cn_filter
    raise 'OpenClash DNS provider changed or missing' unless result.fetch('rule-providers')['oc-cn-domain'] == cn_provider
    raise 'unrelated old provider unexpectedly retained' if result.fetch('rule-providers').key?('unrelated-old-provider')
  end
  puts "OK: #{groups.size} groups, icons, rule priority, subscription and DNS preservation"
end
