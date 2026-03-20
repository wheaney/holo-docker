FROM scratch as builder
ADD ./steamos /
ADD ./steamos/usr/share/factory /
COPY ./packagelists /tmp/packagelists

RUN pacman -Qq | sort -u > /tmp/installed-packages.txt \
 && printf '%s\n' libcroco holo-desync holo-keyring holo-pacman holo-pipewire holo-sudo holo-wireplumber elfutils | sort -u > /tmp/keep-packages.txt \
 && cat /tmp/packagelists/arch.txt /tmp/keep-packages.txt | sort -u > /tmp/base-packages.txt \
 && comm -23 /tmp/installed-packages.txt /tmp/base-packages.txt > /tmp/remove-installed.txt \
 && if [ -s /tmp/remove-installed.txt ]; then xargs pacman -R --noconfirm -- < /tmp/remove-installed.txt; fi \
 && sed -r -i 's/\[(jupiter|core|extra|community|multilib|holo)\]/\[\1-rel\]/g' /etc/pacman.conf \
 && pacman-key --init \
 && pacman-key --populate archlinux \
 && pacman-key --populate holo \
 && pacman -Sy \
#  && comm -1 -2  <(pacman -Qeq | sort) <(pacman -Qoq /usr/include/ | sort) | pacman -S --noconfirm - \
 && comm -1 -2  <(pacman -Qdq | sort | sed "/^filesystem$/d") <(pacman -Qoq /usr/include/ | sort | sed "/^filesystem$/d") | pacman -S --noconfirm --asdeps - \
 && pacman -S --noconfirm gcc make autoconf automake bison fakeroot flex m4 tpm2-tss \
 && yes | pacman -Scc

FROM scratch
COPY --from=builder / /
