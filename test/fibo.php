<?php
  function fibo($a) {
    if ($a < 2) {
      return $a;
    } else {
      return fibo($a - 2) + fibo($a - 1);
    }
  }
  $start = microtime(true);
  echo ">>>" . fibo(40) . "\n";
  echo round(microtime(true) - $start, 3)."ms\n";
