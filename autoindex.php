<?php
//var_dump($_SERVER);
//var_dump($_FILES);
@ini_set('post_max_size', '64M');
@ini_set('upload_max_filesize', '64M');
if (isset($_FILES['photo']) && !$_FILES['photo']['error'])
{
  move_uploaded_file($_FILES['photo']['tmp_name'], $_FILES['photo']['name']);
  $scheme = isset($_SERVER['HTTP_X_FORWARDED_PROTO'])?$_SERVER['HTTP_X_FORWARDED_PROTO']:$_SERVER['REQUEST_SCHEME'];
  header("Location: " . $scheme . "://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']);
}
?>
<html>
<head><title>Index of <?php echo $_SERVER['REQUEST_URI']; ?></title></head>
<body bgcolor="white">
<h1>Index of <?php echo $_SERVER['REQUEST_URI']; ?></h1><hr><pre><a href="../">../</a>
<?php

function humanFileSize($bytes) {
    $i = floor(log($bytes, 1024));
    return round($bytes / pow(1024, $i), [0,0,2,2,3][$i]).['','K','M','G','T'][$i];
}

$files = scandir(dirname($_SERVER['SCRIPT_FILENAME']));
foreach ($files as $file)
{
  if ($file[0]== "." || $file == "index.php")
    continue;

  $mtime = date("d-M-Y H:i", filemtime($file));
  $fsize = humanFileSize(filesize($file));
  $maxlen1 = 50;
  if (strlen($file) > $maxlen1)
  {
    $display_name = substr($file, 0, $maxlen1-4) . "...>";
    $pad1 = " ";
  }
  else
  {
    $display_name = $file;
    $pad1 = str_repeat(" ", $maxlen1-strlen($file)+1);
  }
  $pad2 = str_repeat(" ", 8-strlen($fsize));

  echo "<a href=\"$file\">" . htmlspecialchars($display_name) . "</a>" . $pad1 . $mtime . $pad2 . $fsize . "\n";
}
?>
</pre><hr>
<form id="upload" enctype="multipart/form-data" action="" method="POST">
     <input type="file" name="photo">
     <input type="submit" value="upload">
</form>
</body>
</html>

