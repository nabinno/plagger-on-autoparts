# $FreeBSD: src/share/skel/dot.cshrc,v 1.14.6.1 2008/11/25 02:59:29 kensmith Exp $
#
# .cshrc - csh resource script, read at beginning of execution by each shell
#
# see also csh(1), environ(7).
#

alias h		history 25
alias j		jobs -l
alias la	ls -a
alias lf	ls -FA
alias ll	ls -lA

# A righteous umask
umask 22

set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin)

setenv	EDITOR	vi
setenv	PAGER	more
setenv	BLOCKSIZE	K
setenv	PKG_DBDIR	~/db/pkg

setenv PATH $HOME/local/bin:$PATH
setenv PERL5LIB $HOME/local/lib/perl5:$HOME/local/lib/perl5/site_perl
setenv PKG_DBDIR $HOME/local/var/db/pkg
setenv PORT_DBDIR $HOME/local/var/db/pkg
setenv INSTALL_AS_USER
setenv LD_LIBRARY_PATH $HOME/local/lib

if ($?prompt) then
	# An interactive shell -- set some stuff up
	set filec
	set history = 100
	set savehist = 100
	set mail = (/var/mail/$USER)
	if ( $?tcsh ) then
		bindkey "^W" backward-delete-word
		bindkey -k up history-search-backward
		bindkey -k down history-search-forward
	endif
endif
