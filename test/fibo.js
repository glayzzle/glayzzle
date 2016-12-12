
function fibo(a) {
  return a < 1 ? 1 : fibo(a - 2) + fibo(a - 1);
}
var start = (new Date().getTime()) / 1000;
console.log(">>>" + fibo(30));
var end = (new Date().getTime()) / 1000;
console.log(
  (Math.round((end - start) * 10000) / 10000) + "ms"
);