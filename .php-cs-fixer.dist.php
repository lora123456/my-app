<?php

$finder = PhpCsFixer\Finder::create()
    ->in(__DIR__ . "/src")
    ->in(__DIR__ . "/tests")
    ->name("*.php")
    ->ignoreVCS(true)
    ->ignoreDotFiles(true);

return (new PhpCsFixer\Config())
    ->setRiskyAllowed(true)
    ->setRules([
        "@PSR12" => true,
        "array_syntax" => ["syntax" => "short"],
        "single_quote" => true,
        "no_unused_imports" => true,
        "ordered_imports" => true,
    ])
    ->setFinder($finder);
