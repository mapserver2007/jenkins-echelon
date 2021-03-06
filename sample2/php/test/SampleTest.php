<?php
require_once dirname(__FILE__) . '/../app/Sample.php';

class SampleTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @test
     */
    public function okTestCase()
    {
        $obj = new Sample();
        $this->assertEquals($obj->add(1,2), 3);
    }

    /**
     * @test
     */
    public function okTestSecretFromExternal()
    {
        $obj = new Sample();
        $this->assertEquals($obj->getNameFromYaml(), "hogehoge");
    }
}
