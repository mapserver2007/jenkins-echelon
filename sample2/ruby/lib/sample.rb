require 'yaml'

class Sample
  def add(n1, n2)
    n1 + n2
  end

  def load_secret
    config = YAML.load_file(File.dirname(__FILE__) + "/../config/secret.yml")
    config["key"]
  end
end
