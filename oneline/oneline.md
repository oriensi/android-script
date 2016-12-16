
## 查找一个文件在另一个文件中的位置
```bash
perl -e '$/ = undef; open $f1, "<Calendar.apk" or die "open err1"; open $f2, "<system.img" or die "open err2"; $sub = <$f1>; $origin = <$f2>; $pos = index($origin, $sub); die "cannot find" unless ++$pos > 0; printf "0x%x\n", $pos'
```
### 有多个……
```bash
perl -e '$/ = undef; open $f1, "<framework.odex" or die "open err1"; open $f2, "<system.img" or die "open err2"; $sub = <$f1>; $origin = <$f2>; while( $origin =~ m/\Q$sub\E/g){ $pos = pos($origin); @args = stat($f1); $pos = $pos - $args[7] + 1; printf("0x%x\n", $pos)}'
```

## 生成vcf 文件
```bash
perl -e 'BEGIN{$num = 123456789} { for ($i = "a"; $i lt "z"; $i++ ){ for ($j = 0; $j < 10; $j++ ){ $name = $i."str".$j; $num++; print "BEGIN:VCARD\nVERSION:2.1\nN:;".$name.";;;\nFN:".$name."\nTEL;CELL:".$num."\nEND:VCARD\n" }}}' > 11.vcf
```

## 重命名文件->开关机动画
```bash
rename 's/.*(\d\d.jpg)$/$1/' *.jpg     # 不同系统的rename会不一样   此为ubuntu
```
### 倒序
```bash
perl -e 'while(glob "*.jpg") { $_ =~ /.*(\d\d).jpg$/; $count = 30 - $1; $count = "0".$count if $count < 10; rename $_ => $count.".jpg"}'
```
