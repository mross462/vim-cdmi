" This will not work if vim is not compiled with python, so let's
" check for it.
if !has('python')
    echo "Error: Required vim compiled with +python"
        finish
    endif


function! CDMIE(cdmi_path)
"   CDMIE()
"
"    command! -nargs=0 :cdmie call CDMIE()
"
"    Performs an HTTP GET on a CDMI Resource and
"    opens it in the current buffer as formatted JSON.
"
"    Args
"       cdmi_path : Path to the CDMI Obect to be read into the buffer
"       cdmi_content_type : Content type of the CDMI Object to be read into
"       the buffer
"
"    Raises
"        IOError: An error occurred accessing the bigtable.Table object.


" Begin Python Code
python << EOF

#Now we're in python

import vim
import json
import requests
import time

#Get the args from the VIM Function
path = vim.eval("a:cdmi_path")

#Set our variables that we get from our vimrc
version = vim.eval('g:cdmi_version')
host=vim.eval('g:cdmi_host')
user=vim.eval('g:cdmi_user')
adminpassword = vim.eval('g:cdmi_adminpassword')
secure = bool(vim.eval('g:cdmi_secure'))

try:
    #Create the hdr dict and append our CDMI Version Header
    hdr = {'X-CDMI-Specification-Version': version}

    #Generate The URL
    if secure:
        schema = 'https://'
    else:
        schema = 'http://'

    url = schema + host + path

    # Get the resource
    response = requests.get(url=url,
                headers=hdr,
                auth=(user,
                      adminpassword),
                verify=False)

    print response.status_code
    response_body = response.json

    #Format the response into a list of lines and strip the newline
    formatted_response = json.dumps(response_body, sort_keys=True, indent=4).splitlines()

    #Clear the current buffer
    del vim.current.buffer[:]

    #Add each line of the fomatted output to the buffer
    for line in formatted_response:
        vim.current.buffer.append("%s"%line)

except Exception, e:
    print e

EOF
endfunction


function! CDMIW()
"   CDMIW()
"
"    command! -nargs=0 :cdmie call CDMIE()
"
"    Performs an HTTP PUT of the contents of the current buffer
"
"    Raises


" Begin Python Code
python << EOF
#Now we're in python
import vim
import json
import requests

#Get the args from the VIM Function
version = vim.eval('g:cdmi_version')
host=vim.eval('g:cdmi_host')
user=vim.eval('g:cdmi_user')
adminpassword = vim.eval('g:cdmi_adminpassword')
secure = bool(vim.eval('g:cdmi_secure'))

try:
    #Create the hdr dict and append our CDMI Version Header
    hdr = {'X-CDMI-Specification-Version': version}

    #Generate The URL
    if secure:
        schema = 'https://'
    else:
        schema = 'http://'



    #Get each line in the buffer and write that to payload_data
    payload_data = ''.join(vim.current.buffer)

    #Since the payload_data is a valid json string, lets convert it
    #to a dictionary so we can access the attributes
    payload = json.loads(payload_data)

    #Parse out the content type and objectID from from the payload
    object_path = '/cdmi/cdmi_objectid/' + payload.get('objectID')
    object_type = payload.get('objectType')

    #Add the Content-Type header to the headers list
    hdr['Content-Type'] = object_type

    url = schema + host + object_path

    # Do an HTTP PUT for the Object Resource that was created
    response = requests.put(url=url,
            headers=hdr,
            data=payload_data,
            auth=(user,
                  adminpassword),
            verify=False)

    print response.status_code
    response.raise_for_status()

    # Get the resource
    response = requests.get(url=url,
                headers=hdr,
                auth=(user,
                      adminpassword),
                verify=False)

    response_body = response.json

    #Format the response into a list of lines and strip the newline
    formatted_response = json.dumps(response_body, sort_keys=True, indent=4).splitlines()

    #Clear the current buffer
    del vim.current.buffer[:]
    #Add each line of the fomatted output to the buffer
    for line in formatted_response:
        vim.current.buffer.append("%s"%line)

except Exception, e:
    print e

EOF
endfunction
