import types

def doctype():
    return """
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">"""


def build( items ):
    rv = []
    for item in items:
        if type( item ) is types.ListType:
            rv.append( apply( build( item )) )
        else:
            rv.append( apply( item ) )
    return lambda: "".join( rv )


def html( *args ):
    child = []
    for arg in args:
        child.append( arg )

    return lambda: "".join( [ doctype(), '\n<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">\n', apply( build( child ) ), '</html>\n' ] )


def head( title, author, stylesheet ):
    return lambda: """<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<meta name="author" content="%s" />
<meta name="robots" content="all" />
<link rel="stylesheet" type="text/css" href="%s" title="" />
<title>%s</title> />
</head> 
""" % ( author, stylesheet, title )

def singleElement( content, tag, child ):
    if content != "":
        content = " " + content
    return lambda: "".join( 
        [ "<%s%s>\n" % (tag, content), 
        apply(child), 
        "</%s>\n" % (tag) ] )

def multipleElements( content, tag, args ):
    if content != "":
        content = " " + content
    return lambda: "".join(
        [ "<%s%s>\n" % (tag, content),
        apply( build ( args ) ),
        "</%s>\n" % (tag) ] )

def body( content="", *args ):
    return multipleElements( content, "body", args )

def p( content, *args ):
    return multipleElements( content, "p", args )

def i( content, *args ):
    return multipleElements( content, "i", args )

def table( content, *args ):
    return multipleElements( content, "table", args )

def tr( content, *args ):
    return multipleElements( content, "tr", args )

def td( content, *args ):
    return multipleElements( content, "td", args )

def div( content, *args ):
    return multipleElements( content, "div", args )

def img( content, *args ):
    return multipleElements( content, "img", args )

def h1( content, *args ):
    return multipleElements( content, "h1", args )

def a( content, *args ):
    return multipleElements( content, "a", args )

def ul( content, *args ):
    return multipleElements( content, "ul", args )

def li( content, *args ):
    return multipleElements( content, "li", args )

def text( child ):
    return lambda: (child + "\n")


def chain( list ):
    return lambda: apply( build ( list ) )

def y( tag, l ):
    return lambda: "".join( [ '<%s>'%(tag), apply(build( l )), '</%s>'%(tag) ] )
