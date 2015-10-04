void loop();
void __attribute__((weak)) vApplicationIdleHook() {
  //loop(); Don't do anything in the idle hook
  for(;;);
}
void __attribute__((weak)) vApplicationTickHook() {
}