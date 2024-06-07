## Installing Gleam

I use [asdf](https://asdf-vm.com/) to manage [Gleam installations](https://github.com/asdf-community/asdf-gleam) (among other languages). If I didn't have any of this installed today, I'd open my terminal and do this:

```sh
# First, install asdf (see: https://asdf-vm.com/guide/getting-started.html#_2-download-asdf)
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc

# Next, install erlang
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
brew install autoconf openssl wxwidgets libxslt fop
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
asdf install erlang latest
asdf global erlang latest

# Then, install Node.js
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

# Finally, install Gleam
asdf plugin-add gleam https://github.com/asdf-community/asdf-gleam.git
asdf install gleam latest
asdf global gleam latest

```

A couple notes here:
- This works as of Wednesday, June 5th, 2024
- It's up to you to decide whether you want to use `asdf global` for Node.js and Erlang. You can always change versions in local directories using `asdf local`, but I recommend setting _something_ globally.
