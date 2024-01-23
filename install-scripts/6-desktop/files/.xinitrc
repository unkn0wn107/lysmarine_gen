export XDG_CURRENT_DESKTOP=Budgie:GNOME
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# See: https://bugs.chromium.org/p/chromium/issues/detail?id=1514700
export CHROMIUM_FLAGS=--password-store=basic

exec budgie-desktop $*

