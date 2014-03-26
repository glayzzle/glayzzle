Hello world :
<?php
function fibo($x) {
    if ($x < 2) {
        return $x;
    } else {
        return fibo($x - 1) + fibo($x - 2);
    }
}
$start = microtime(true);
echo 'The result is : ' . fibo(30) . "\n";
echo 'Run in ' . round( microtime(true) - $start, 3) . "sec\n";
