vim-cdmi
========

A VIM Plugin For CDMI.

For questsions email: mross@mezeo.com

#Configuration:

Add the following attributes to your vimrc:

    let g:cdmi_version="1.0.1'
    let g:cdmi_host="mcsp1.cloud"
    let g:cdmi_user="administrator"
    let g:cdmi_adminpassword="wnxy68Z/CJYDIfDsJ9qoWg"
    let g:cdmi_secure=True

    :command -nargs=+ -complete=command CDMIe call CDMIE(<f-args>)
    :command CDMIw call CDMIW()

Open a vim buffer:

    vim

Source the vim file:

    :source vim-cdmi/vim-cdmi.vim

Note: You can have pathogen source this for you everytime vim load

Get a CDMI Object and write it into the buffer:

    :CDMIe /cdmi

Write the object in the current buffer to the CDMI Server

    :CDMIw


