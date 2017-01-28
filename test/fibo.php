<?php
function fibo($a) {
  return $a < 1 ? 1 : fibo($a - 2) + fibo($a - 1);
}
$start = microtime(true);
echo ">>>" . fibo(30) . "\n";
echo round(microtime(true) - $start, 3)."ms\n";
