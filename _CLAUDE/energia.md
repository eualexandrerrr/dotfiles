# Energia: nunca dorme

Nunca suspende, nunca hiberna, nunca desliga sozinha -- so por pedido explicito. A unica
coisa que a inatividade faz e apagar os monitores em 5 min. Tres camadas (`kde/energia.sh`):
PowerDevil, alvos do systemd **mascarados** e `IdleAction=ignore` no logind. So a do KDE nao
seguraria um `systemctl suspend`; com os alvos mascarados ele responde "Access denied".

