# encoding: UTF-8
require 'yaml'

config_file = ARGV[0]
raise 'missing config path' if config_file.nil? || config_file.empty?
raise "config not found: #{config_file}" unless File.exist?(config_file)

value = YAML.load_file(config_file)
value ||= {}

all_proxy_names = Array(value['proxies']).filter_map do |proxy|
  name = proxy.is_a?(Hash) ? proxy['name'] : nil
  name if name.is_a?(String) && !name.empty?
end

region_patterns = {
  'HK' => /(🇭🇰|香港|Hong|HK)/i,
  'US' => /(🇺🇸|美国|States|US)/i,
  'JP' => /(🇯🇵|日本|Japan|JP)/i,
  'TW' => /(🇹🇼|台湾|台灣|Taiwan|TW|🇨🇳 台湾)/i,
  'SG' => /(🇸🇬|新加坡|Singapore|SG)/i
}

region_names = {}
region_patterns.each do |region, pattern|
  nodes = all_proxy_names.select { |name| name.match?(pattern) }
  nodes = all_proxy_names.dup if nodes.empty?
  nodes = ['DIRECT'] if nodes.empty?
  region_names[region] = nodes.uniq
end

groups = []
groups << {
  'name' => 'Proxies',
  'type' => 'select',
  'proxies' => (['HK', 'JP', 'SG', 'TW', 'US'] + all_proxy_names).uniq
}
groups << {'name' => 'Final', 'type' => 'select', 'proxies' => ['Proxies', 'DIRECT']}
groups << {'name' => 'Google', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Apple', 'type' => 'select', 'proxies' => ['Proxies', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'OpenAI', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Claude', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'YouTube', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Netflix', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Disney', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'HBOMax', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Bahamut', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'TW']}
groups << {'name' => 'BiliBili', 'type' => 'select', 'proxies' => ['DIRECT', 'HK', 'TW']}
groups << {'name' => 'Spotify', 'type' => 'select', 'proxies' => ['Proxies', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Steam', 'type' => 'select', 'proxies' => ['Proxies', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Telegram', 'type' => 'select', 'proxies' => ['Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Microsoft', 'type' => 'select', 'proxies' => ['Proxies', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'GitHub', 'type' => 'select', 'proxies' => ['Proxies', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'PayPal', 'type' => 'select', 'proxies' => ['Proxies', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Link', 'type' => 'select', 'proxies' => ['PayPal', 'Proxies', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US']}
groups << {'name' => 'Speedtest', 'type' => 'select', 'proxies' => ['DIRECT', 'Proxies', 'HK', 'JP', 'SG', 'TW', 'US']}
%w[HK JP SG TW US].each do |region|
  groups << {'name' => region, 'type' => 'select', 'proxies' => region_names[region]}
end
value['proxy-groups'] = groups

value['rule-providers'] ||= {}
value['rule-providers'].merge!(
  'YouTube' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/YouTube.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/youtube.clash.yaml','interval'=>86400},
  'Disney' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Disney.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/disney.clash.yaml','interval'=>86400},
  'HBOMax' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/HBOMax.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/hbomax.clash.yaml','interval'=>86400},
  'Netflix' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Netflix.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/netflix.clash.yaml','interval'=>86400},
  'Bahamut' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Bahamut.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/bahamut.clash.yaml','interval'=>86400},
  'BiliBili' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/BiliBili.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/bilibili.clash.yaml','interval'=>86400},
  'Spotify' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Spotify.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/spotify.clash.yaml','interval'=>86400},
  'Steam' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Steam.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/steam.clash.yaml','interval'=>86400},
  'Telegram' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Telegram.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/telegram.clash.yaml','interval'=>86400},
  'Google' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Google.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/google.clash.yaml','interval'=>86400},
  'Microsoft' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Microsoft.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/microsoft.clash.yaml','interval'=>86400},
  'GitHub' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/GitHub.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/github.clash.yaml','interval'=>86400},
  'OpenAI' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/OpenAI.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/openai.clash.yaml','interval'=>86400},
  'Claude' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Claude.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/claude.clash.yaml','interval'=>86400},
  'PayPal' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/PayPal.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/paypal.clash.yaml','interval'=>86400},
  'Link' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Link.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/link.clash.yaml','interval'=>86400},
  'Apple' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Apple.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/apple.clash.yaml','interval'=>86400},
  'Speedtest' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Speedtest.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/speedtest.clash.yaml','interval'=>86400},
  'Global' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Global.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/global.clash.yaml','interval'=>86400},
  'Pixiv' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Pixiv.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/pixiv.clash.yaml','interval'=>86400},
  'China' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/China.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/china.clash.yaml','interval'=>86400},
  'Lan' => {'type'=>'http','behavior'=>'classical','path'=>'./rule_provider/Lan.yaml','url'=>'https://raw.githubusercontent.com/Aioneas/Surge/main/List/lan.clash.yaml','interval'=>86400}
)

custom_rule_file = '/etc/openclash/custom/openclash_custom_rules.list'
if File.exist?(custom_rule_file)
  custom_data = YAML.load_file(custom_rule_file)
  if custom_data.is_a?(Hash) && custom_data['rules'].is_a?(Array)
    value['rules'] = custom_data['rules']
  end
end

value['mode'] = 'rule'
value['log-level'] ||= 'info'
value['ipv6'] = false if value.key?('ipv6')

File.open(config_file, 'w') { |f| YAML.dump(value, f) }
puts "#{Time.now.strftime('%F %T')} Info: Aioneas OpenClash overwrite applied successfully."
