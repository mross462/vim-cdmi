vim-cdmi
========

A VIM Plugin for that will load CDMI objects into a VIM buffer. The user can make
changes to the object, and then write it back to the server.

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

Interacting with CDMI
--------------------

###Get a CDMI Object and write it into the buffer:

    :CDMIe /cdmi 

###Get of a child of the object in the curent buffer: 

    :CDIMe /cdmi 

Returns the following children:

    "children": [
        "cdmi_capabilities/", 
        "cdmi_domains/", 
        "storage_root/", 
        "system_configuration/"
    ], 

To Get the storage_root child:

    :CDMIe /storage_root

###Get the parent object of the current buffer:

    :CDMIe ..

###Write the object in the current buffer to the CDMI Server

    :CDMIw
