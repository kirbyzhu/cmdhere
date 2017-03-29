<?php
define("PASSWORD", "123");
//var_dump($_SERVER);
//var_dump($_FILES);
if (isset($_FILES['photo']) && !$_FILES['photo']['error'])
{
  if (PASSWORD != "" && $_POST['password'] != PASSWORD)
  {
    echo '<!DOCTYPE html><script>alert("incorrect password");location=location.href;</script>';
  }
  else
  {
    $filename = $_FILES['photo']['name'];
    if (substr($filename, -4) == '.php')
    {
      $filename .= '.txt';
    }
    move_uploaded_file($_FILES['photo']['tmp_name'], $filename);
    $scheme = isset($_SERVER['HTTP_X_FORWARDED_PROTO'])?$_SERVER['HTTP_X_FORWARDED_PROTO']:$_SERVER['REQUEST_SCHEME'];
    echo '<!DOCTYPE html><script>location=location.href;</script>Upload Finished.';
  }
}
?>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<title>Index of <?php echo $_SERVER['REQUEST_URI']; ?></title>
<h1>Index of <?php echo preg_replace('/\?.*/', '', $_SERVER['REQUEST_URI']); ?></h1>
<hr>
<pre><a href="../">../</a>
<?php

function human_filesize($bytes, $decimals = 1) {
  $sz = 'BKMGTP';
  $factor = floor((strlen($bytes) - 1) / 3);
  $hz = sprintf("%.{$decimals}f", $bytes / pow(1024, $factor));
  $unit = @$sz[$factor];
  if (($pos=strpos($hz, '.')) > 0)
  {
    if ($pos >= 3)
      $hz = substr($hz, 0, $pos);
    else if ($pos >= 2)
      $hz = substr($hz, 0, $pos+2);
    else if (substr($hz, $pos+1, 1) == '0')
      $hz = substr($hz, 0, -2);
  }
  return $hz . ($unit == 'B' ? '' : $unit);
}

function is_mobile() {
  return preg_match("/(android|avantgo|blackberry|bolt|boost|cricket|docomo|fone|hiptop|mini|mobi|palm|phone|pie|tablet|up\.browser|up\.link|webos|wos)/i", $_SERVER["HTTP_USER_AGENT"]);
}

$files = scandir(dirname($_SERVER['SCRIPT_FILENAME']));
usort($files, function ($a, $b) {
    $aIsDir = is_dir($a);
    $bIsDir = is_dir($b);
    if ($aIsDir === $bIsDir)
        return strnatcasecmp($a, $b); // both are dirs or files
    elseif ($aIsDir && !$bIsDir)
        return -1; // if $a is dir - it should be before $b
    elseif (!$aIsDir && $bIsDir)
        return 1; // $b is dir, should be before $a
});
foreach ($files as $file)
{
  if ($file[0] == '.' || $file == 'index.php')
    continue;

  if (strtolower($file) == 'readme.md')
    $readme = file_get_contents($file);

  $mtime = date("d-M-Y H:i", filemtime($file));
  $fsize = human_filesize(filesize($file));
  if (is_mobile())
  {
    $maxlen1 = 22;
  }
  else
  {
    $maxlen1 = 50;
  }
  if (strlen($file) > $maxlen1)
  {
    $display_name = substr($file, 0, $maxlen1-4) . "...>";
    $pad1 = " ";
  }
  else
  {
    $display_name = $file . (is_dir($file) ? '/' : '');
    $pad1 = str_repeat(" ", $maxlen1-strlen($display_name)+1);
  }
  $pad2 = str_repeat(" ", 8-strlen($fsize));

  echo "<a href=\"$file\">" . htmlspecialchars($display_name) . "</a>" . $pad1 . $mtime . $pad2 . $fsize . " \n";
}
?>
</pre>
<hr>
<form id="upload" enctype="multipart/form-data" method="POST">
  <pre><input type="submit" style="display:none" id="upload_button" value="Upload File"><span id="upload_name"></span><span id="password0" style="display:none"> <input type="password" id="password" name="password" placeholder="password" ></span></pre>
  <input type="file" id="photo" name="photo">
  <noscript><input type="submit" value="Upload"></noscript>
</form>
<script>
$ = typeof($) == "undefined" ? (function (x) {return document.getElementById(x.replace(/^#/, ''))}) : $;
$("#photo").onchange = function () {
  if (/^zh/.test((navigator.language || navigator.userLanguage))) {
    $('#upload_button').value = "上传文件";
  }
  $('#upload_button').style.display = "";
  $('#upload_button').onclick = function () {
    $('#upload').submit();
  };
  $('#upload_name').innerHTML = ' ' + $('#photo').value;
  $('#photo').style.display = "none";
  <?php if (PASSWORD != ""): ?>
  $('#password0').style.display = "";
  if (!navigator.userAgent.match(/Trident/g) && !navigator.userAgent.match(/MSIE/g))
  {
    $('#password').focus();
  }
  $('#upload').onsubmit = function () {
    $('#password').readOnly = true
    $('#password').style.backgroundColor = '#ebebe4'
  }
  <?php endif ?>
};
</script>

<?php if (isset($readme)) : ?>
<textarea id="readme" style="display:none"><?php echo $readme; ?></textarea>
<link href="https://rawgit.com/phuslu/cmdhere/master/marked.min.css" rel="stylesheet">
<div id="readme-markdown" class='marked' style='float:left;' ></div>
<script src="https://cdn.staticfile.org/reveal.js/3.3.0/plugin/markdown/marked.js"></script>
<script>document.getElementById('readme-markdown').innerHTML = marked(document.getElementById('readme').value);</script>
<?php endif; ?>

