vim-cdmi
========

A VIM Plugin For CDMI.

For questsions email: mross@mezeo.com

#Dependencies

The vim-cdmi plugin requires vim to be compiled with python support. To check this:

    vim --version | grep +python

Also the requests python package should be installed on the system:

    pip install requests

#Installation

Using pathogen, simply run:

    cd ~/.vim/bundle
        git clone git://github.com/mross462/vim-cdmi.git

#Configuration:

Add the following to your vimrc:

    let g:cdmi_version="1.0.1'
    let g:cdmi_host="mcsp1.cloud"
    let g:cdmi_user="administrator"
    let g:cdmi_adminpassword="wnxy68Z/CJYDIfDsJ9qoWg"
    let g:cdmi_secure="True"

Get a CDMI Object and write it into the buffer:

    :CDMIe /cdmi

Write the object in the current buffer to the CDMI Server

    :CDMIw
