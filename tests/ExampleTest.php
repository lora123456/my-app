<?php

declare(strict_types=1);
use App\Hello;
use PHPUnit\Framework\TestCase;

final class ExampleTest extends TestCase
{
    public function test_it_works(): void
    {
        $this->assertSame('Hello, World', Hello::greet('World'));
    }
}
