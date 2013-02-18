
" Vim Needs to be compiled with python, so let's check for it.
if !has('python')
    echo "Error: Vim needs to be compiled with +python support"
        finish
    endif

" Declare commands for vim
:command -nargs=+ -complete=command CDMIe call CDMIE(<f-args>)


function! CDMIE(cdmi_path)
"   CDMIE()
"
"    command! -nargs=0 :cdmie call CDMIE()
"
"    Performs an HTTP GET on a CDMI Resource and opens it in 
"    the current buffer as formatted JSON.
"
"    Args
"       cdmi_path : Path to the CDMI Obect to be read into the buffer
"
"    Raises
"        Exception: Any python exception is caught and reported
"
"

" Load the syntax file from the repo

" Create a temporary file for the buffer
w! $TMPDIR/tmp.cdmi

" Turn on syntax highlighting for a CDMI JSON object
au! BufRead,BufNewFile *.cdmi set filetype=cdmi
au! Syntax cdmi source ./plugin/cdmi_syntax.vim
let b:current_syntax = "cdmi"

" Begin Python Code
python << EOF
#Now we're in python
import vim
import json
import requests
import types
from time import localtime, strftime

# Get the args from the VIM Function
path = vim.eval("a:cdmi_path").rstrip("/").lstrip("/")

# Convert the variables from vimL to python
version = vim.eval('g:cdmi_version')
host=vim.eval('g:cdmi_host')
user=vim.eval('g:cdmi_user')
adminpassword = vim.eval('g:cdmi_adminpassword')
secure = bool(vim.eval('g:cdmi_secure'))

# Try to make a get request on the object. Raise an exception if
# one occurs.
try:

    # Check to see if the current buffer conatins a CDMI object
    buffer_data = ''.join(vim.current.buffer)

    children = []

    try:
        current_object = {}
        current_object = json.loads(buffer_data)

        #Get the attributes that we need from the current object
        parent = current_object.get('parentURI')
        obj = current_object.get('objectName')
        children = current_object.get('children', [])

    except ValueError, TypeError:
        # The object in the buffer is not json serializeable and
        # is not a CDMI object.
        pass

    #Create the hdr dict and append our CDMI Version Header
    hdr = {'X-CDMI-Specification-Version': version}

    #Generate The URL
    if secure is "True":
        schema = 'https://'
    else:
        schema = 'http://'

    '''
    Determine if the path specified in the function args is contained 
    in the children of current object in the buffer. If it isn't, default
    to an empty list.
    '''

    if path == '.':
        if obj == '/':
            url = schema + host + obj
        else:
            url = schema + host + parent + obj 

    elif path == '..':
        #Navigate to the parent object
        if obj == '/':
            print 'You are at the top level object.'
        else:
            url = schema + host + parent

    #Check to see if the children list is empty,
    elif len(children) == 0:
        #We know the path is an relative URI
        url = schema + host + '/' + path

    elif path + '/' in children or \
         path in children:

         if obj == '/':
            #The current object is the CDMI endpoint
            url = schema + host + '/cdmi/' + path

         else:
            #The current object is not the CDMI endpoint
            obj.rstrip('/')
            url = schema + host + parent + obj + '/' + path

    else:
        url = schema + host + '/' + path
    # Mark the time the request is made
    request_time = strftime("Local:%a, %d %b %Y %H:%M:%S +0000", localtime())

    '''

    This Client is designed to be innocent of the objectType
    it is requesting. The current CDMI Spec requires that a GET of 
    an object that has children to have a trailing '/' otherwise 
    return a 409 status code. Since this is the case, the client Needs
    to be smart about what it receives, and append that '/' if 
    necessary

    '''

    if user is None:
        #This CDMI Server Does Not Require Authentication
        response = requests.get(url=url,
                headers=hdr,
                verify=False)

        if response.status_code == 409:
            #We need to append a '/'
            url = url + '/'

        if secure is True:
            response = requests.get(url=url,
                headers=hdr,
                verify=False)
        else:
            response = requests.get(url=url,
                headers=hdr)

    else:
        #This CDMI Server Requires Authentication
        response = requests.get(url=url,
                headers=hdr,
                auth=(user,
                    adminpassword),
                verify=False)

        if response.status_code == 409:
            #We need to append a '/'
            url = url + '/'

        if secure is True:
            response = requests.get(url=url,
                    headers=hdr,
                    auth=(user,
                        adminpassword),
                    verify=False)
        else:
            response = requests.get(url=url,
                headers=hdr,
                auth=(user,
                      adminpassword))

    #If there is an HTTP error raise it
    response.raise_for_status()

    # Print out some basic information in the vim terminal for the user
    print 'Object: %s' % url
    print 'GET Status: %s' % response.status_code
    print 'Time: %s' % request_time

    response_body = response.json()

    if response.status_code <= 400:
        #Write the object to the buffer

        #Clear the current buffer
        del vim.current.buffer[:]

        #Format the response into a list of lines and strip the newline
        formatted_response = json.dumps(response_body, sort_keys=True, indent=4).splitlines()

        #Add each line of the fomatted output to the buffer
        for line in formatted_response:
            vim.current.buffer.append("%s"%line)

except Exception, e:
    print e

EOF

" Write the contents of the buffer to the temp file
w! $TMPDIR/tmp.cdmi
endfunction


:command CDMIw call CDMIW()
function! CDMIW()
"   CDMIW()
"
"    :command CDMIw call CDMIW()
"
"    Performs an HTTP PUT of the current buffer contents to a CDMI 
"    Resource
"
"    Args:
"       None
"
"    Raises
"        Exception: Any python exception is caught and reported
"
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
    # Create the hdr dict and append our CDMI Version Header
    hdr = {'X-CDMI-Specification-Version': version}

    # Generate The URL
    if secure is True:
        schema = 'https://'
    else:
        schema = 'http://'

    # Get each line in the buffer and write that to payload_data
    payload_data = ''.join(vim.current.buffer)

    # Since the payload_data is a valid json string, lets convert it
    #to a dictionary so we can access the attributes
    payload = json.loads(payload_data)

    # Parse out the content type and objectID from from the payload
    object_path = '/cdmi/cdmi_objectid/' + payload.get('objectID')
    object_type = payload.get('objectType')

    # Add the Content-Type header to the headers list
    hdr['Content-Type'] = object_type

    url = schema + host + object_path

    #Clear the current buffer
    del vim.current.buffer[:]

    if user is None:
        #this cdmi server doesn't require authentication:
        response = requests.put(url=url,
                data=payload_data,
                headers=hdr,
                verify=false)
    else:
        # Do an HTTP PUT for the Object Resource that was created
        response = requests.put(url=url,
                headers=hdr,
                data=payload_data,
                auth=(user,
                    adminpassword),
                verify=False)

    # Print out some basic information in the vim terminal for the user
    print 'Object: %s' % url
    print 'PUT Status: %s' % response.status_code
    print 'Time: %s' % request_time

    response.raise_for_status()

    if user is None:
        #This CDMI Server Does Not Require Authentication
        response = requests.get(url=url,
                headers=hdr,
                verify=False)

    else:
        #This CDMI Server Requires Authentication
        response = requests.get(url=url,
                headers=hdr,
                auth=(user,
                    adminpassword),
                verify=False)

    if response.status_code <= 400:
        #Write the new line to the buffer

        # Format the response into a list of lines and strip the newline
        formatted_response = json.dumps(response_body, sort_keys=True, indent=4).splitlines()

        # Clear the current buffer
        del vim.current.buffer[:]

        # Add each line of the fomatted output to the buffer
        for line in formatted_response:
            vim.current.buffer.append("%s"%line)

except Exception, e:
    print e

EOF

"Write the buffer to a file so syntax highlighting will work
w! $TMPDIR/tmp.cdmi

endfunction
