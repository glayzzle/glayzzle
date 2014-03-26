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
echo fibo(35);
echo 'Run in ' . (microtime(true) - $start);
