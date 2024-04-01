# Limpando todas as regras existentes
iptables -F
iptables -X

# Definindo a política padrão como DROP (bloquear tudo)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitindo conexões de loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Estabeleça a política DROP (restritiva) para as chains INPUT e FORWARD da tabela filter.
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Possibilite que usuários da rede interna possam acessar o serviço WWW, tanto na porta (TCP) 80 como na 443. Não esqueça de realizar NAT já que os usuários internos não possuem um endereço IP válido

iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
iptables -A FORWARD -i enp0s8 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i enp0s8 -p tcp --dport 443 -j ACCEPT

# Faça LOG e bloqueie o acesso a qualquer site que contenha a palavra “games”
iptables -A FORWARD -i enp0s8 -p tcp --dport 80 -m string --string "games" --algo bm -j LOG --log-prefix "Games: "

# Bloqueie acesso para qualquer usuário ao site www.jogosonline.com.br, exceto para seu chefe, que possui o endereço IP 10.1.1.100

iptables -A FORWARD -i 10.1.1.100 -p tcp --dport 80 -d www.jogosonline.com.br -j ACCEPT
iptables -A FORWARD -i enp0s8 -p tcp --dport 80 -d www.jogosonline.com.br -j DROP

# permita que o firewall receba pacotes do tipo ICMP echo-request (ping), porém, limite a 5 pacotes por segundo

iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/s -j ACCEPT