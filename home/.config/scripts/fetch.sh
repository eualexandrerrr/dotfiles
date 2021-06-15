#!/bin/zsh
#PROJETO FETCH
# Create by Odilon Coelho (gtihub.com/odilonscoelho)
# the ascii logos were inspired by this project https://github.com/konfou/neofetch-sh
# Dependencies: zsh - it doesn't have to be your default shell, just have it installed.

arch () #
{
info () #
{
printf '%b' "		$corIcon  $reset $cyan $user
		$corIcon  $reset $corDesc $kernel
		$corIcon  $reset $corDesc $pkgs $(print -P %F{cyan}pkgs%f)
		$corIcon  $reset $corDesc $cpu
	$corIcon  $reset $corDesc $wm
	$corIcon  $reset $corDesc $videoext
	$corIcon  $reset $corDesc $shell
	$corIcon  $reset $corDesc $uptime
	$corIcon  $reset  $(print -P %B%K{red}%F{black}"$(printf %8s " $memused ")"%k) $(print -P %K{green}"$(printf %8s " $memfree ")"%k) $(print -P %K{magenta}"$(printf %8s " $memtotal ")"%k%f%b)
	$corIcon  $reset  $(print -P %K{cyan}%F{black}%B"$(printf '%-8s' " ${mtg1//*\/} ")"%k) $(print -P %K{cyan}"$(printf '%8s' " $usedp1% ")" %k) $(print -P %K{cyan}"$(printf '%8s' " $used1 ")"%b%k%f)
	$corIcon  $reset  $(print -P %K{green}%F{black}%B"$(printf '%-8s' " ${mtg2//\//sys} ")"%k) $(print -P %K{green}"$(printf '%8s' "$usedp2% ")" %k) $(print -P %K{green}"$(printf '%8s' " $used2 ")"%b%k%f)
$corIcon  $reset  $(print -P %K{yellow}%F{black}%B"$(printf '%-8s' " ${mtg3//*\/} ")"%k) $(print -P %K{yellow}"$(printf '%8s' " $usedp3% ")" %k) $(print -P %K{yellow}"$(printf '%8s' " $used3 ")"%b%k%f)

$(blockColors)
$reset
"
}

logo () #
{
<< doc
                   -\`
                  .o+\`
                 \`ooo/
                \`+oooo:
               \`+oooooo:
              \`-+oooooo+:
             \`/:-:++oooo+:
            \`/++++/+++++++:
           \`/++++++++++++++:
          \`/+++ooooooooooooo/\`
         ./ooosssso++osssssso+\`
        .oossssso-\`\`\`\`/ossssss+\`
       -osssssso.      :ssssssso.
      :osssssss/        osssso+++.
     /ossssssss/         +ssssooo/-
   \`/ossssso+/:-         -:/+osssso+-
  \`+sso+:-\`                  \`.-/+oso:
 \`++:.                            \`-/+/
.\\\\´                                   \`/
doc
}
$@
}

gnu () #
{
info () #
{
printf '%b' "

$(blockColors)

$corIcon  $reset $cyan $user
$corIcon  $reset $corDesc $kernel
	$corIcon  $reset $corDesc $pkgs $(print -P %F{cyan}pkgs%f)
	$corIcon  $reset $corDesc $wm
	$corIcon  $reset $corDesc $shell
	$corIcon  $reset $corDesc $uptime
	$corIcon  $reset $corDesc $cpu
	$corIcon  $reset $corDesc $videoext
	$corIcon  $reset
		$corIcon  $reset
		$corIcon  $reset
				$corIcon  $reset

	$reset
"
# $corIcon  $reset $corDesc $(printf '%11s' "$(print -P %B%K{red}%F{black}" $memused "%k%f%b)") $(printf '%10s' "$(print -P %B%K{green}%F{black}" $memfree "%k%f%b)") $(printf '%10s' "$(print -P %B%K{cyan}%F{black}"  $memtotal  "%k%f%b)")
}
logo () #
{
<< doc

   _-\`\`\`\`\`-,           ,- '- .
  .'   .- - |          | - -.  \`.
 /.'  /                     \`.   \\
:/   :      _...   ..._      \`\`   :
::   :     /._ .\`:'_.._\.    ||   :
::    \`._ ./  ,\`  :    \ . _.''   .
\`:.      /   |  -.  \-. \_      /
  \:._ _/  .'   .@)  \@) \` \`\ ,.'
     _/,--'       .- .\,-.\`--\`.
       ,'/''     (( \ \`  )
        /'/'  \    \`-'  (
         '/''  \`._,-----'
          ''/'    .,---'
           ''/'      ;:
             ''/''  ''/
               ''/''/''
                 '/'/'
                  \`;

doc
}
$@
}

disks ()
{
	unset control
	for dev in $@
	{
		control=$((control+1))
		df -h $dev |sed -n 2p |read label$control size$control used$control avail$control usedp$control mtg$control
	}
}

blockColors ()
{
	baliza=$(($(wc -c <<< "$videoext")+3))
	qt_cols_banner=$(( baliza / 4  ))
	print -P "%K{black}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{red}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{green}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{yellow}$(printf '%'$qt_cols_banner's' "")%k%f%b"
	print -P "%K{8}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{9}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{10}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{11}$(printf '%'$qt_cols_banner's' "")%k%f%b"
	print
	print -P "%K{blue}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{magenta}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{cyan}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{white}$(printf '%'$qt_cols_banner's' "")%k%f%b"
	print -P "%K{12}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{13}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{14}$(printf '%'$qt_cols_banner's' "")%k%f%b %K{15}$(printf '%'$qt_cols_banner's' "")%k%f%b"
}

# Infos
# Coleta das informaçoes dos discos
disks /dev/sda2
user="github.com/mamutal91"
read hostname kernel <<< ${(s: :)$(uname -a)[2,3]}
uptime=${(s: :)$(uptime)[3]//,/}
free -h |sed -n 2'p'|awk {'print $3" "$7" "$2'} |read memused memfree memtotal
head /proc/cpuinfo|grep "model name"|awk {'print $4,$5,$6,$7,$8'} |read cpu
lspci |grep VGA|awk {'print $7,$8,$9,$10,$11'}|sed 's/]//g'|sed 's/\[//g' | read videoext
wm="sway"
shell=$(grep $USER /etc/passwd |cut -d ':' -f7)
pacman -Q | wc -l |read pkgs


# Colors
white=$(tput setaf 7;)
blue=$(tput setaf 4;)
yellow=$(tput setaf 3;)
magenta=$(tput setaf 5;)
cyan=$(tput setaf 6;)
green=$(tput setaf 2;)
red=$(tput setaf 1;)
black=$(tput setaf 0;)
bold=$(tput bold;)
reset=$(tput sgr0;)

# Verifica se há argumentos, se o script não for chamado com o argumento "gnu"
# vai executar com a lago ascii do arch padrão
[ -n $@ ] && art=$1 || art=arch

# Gera informaçoes de acordo com a art escolhida
case $art in
	arch )
		corLogo="$yellow"
		corIcon="$bold $blue"
		corDesc="$green"
		$art info > /tmp/fetchInfo ;;
	gnu )
		corLogo="$bold $red"
		corIcon="$bold $red"
		corDesc="$green"
		$art info > /tmp/fetchInfo ;;
esac

# Ajuste  do logo :
$art logo > /tmp/fetchx

for line in {1..$(wc -l < /tmp/fetchx)}
{
	echo -e "$corLogo$(< /tmp/fetchx |sed -n ''$line'p')"
} > /tmp/fetchLogo

# Clear display
clear

# Executa :
paste "/tmp/fetchLogo" "/tmp/fetchInfo"

# Exclui files temporários
rm /tmp/fetchx /tmp/fetchLogo /tmp/fetchInfo
