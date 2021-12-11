<?php

/*
 * Available options can be found here:
 * https://mlocati.github.io/php-cs-fixer-configurator/#version:3.0
 */

$config = new PhpCsFixer\Config();

return $config
    ->setRules([
        '@PSR12' => true,
        '@Symfony' => true,
        'strict_param' => true,
        'array_syntax' => ['syntax' => 'short'],
        'yoda_style' => false,
        'phpdoc_to_comment' => false,
    ]);
