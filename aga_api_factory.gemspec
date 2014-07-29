# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aga_api_factory/version'

Gem::Specification.new do |spec|
  spec.name          = "aga_api_factory"
  spec.version       = AgaApiFactory::VERSION
  spec.authors       = ["fbsender"]
  spec.email         = ["liuyu_tc@163.com"]
  spec.description   = "搜索引擎API通用调用 baidu qihu sogou"
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_dependency "baidu"
  spec.add_dependency "qihu360"
  spec.add_dependency "json"
  spec.add_dependency "sogou"
end
