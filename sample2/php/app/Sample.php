<?php
require __DIR__ . "/../vendor/autoload.php";

class Sample
{
    public function add($n1, $n2)
    {
        return $n1 + $n2;
    }

    public function getNameFromYaml()
    {
        $secret = \Spyc::YAMLLoad(dirname(__FILE__) . "/../config/secret.yml");
        return $secret["key"];
    }
}
