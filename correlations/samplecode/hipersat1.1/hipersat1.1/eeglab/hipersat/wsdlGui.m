function x = wsdlGui( path )
% this is very simple and brittle

% Set up the service
service = createClassFromWsdl( path );

% parse the help of the service to discover the methods it has
serviceHelp = help( service );
[beg, en] = regexp( serviceHelp, '[a-zA-Z]+(', 'start', 'end' );
matches = size(beg);
functionNames = cell( matches(2), 1 );
for i = 1:matches(2)
    functionName = serviceHelp( beg(i):en(i)-1 );
    functionNames(i) = cellstr( functionName );
end

% parse the help of the functions to discover the input and output
functionMeta = cell( matches(2), 4 );
for i = 1:matches(2)
    % set the name of the function
    functionMeta(i,1) = functionNames( i, 1 );
    
    % obtain and set the help string of the function
    helpval = help( strcat( service, '/', char( functionNames(i) ) ) );
    functionMeta(i,2) = cellstr( helpval );
    
    % find the inputs and outputs
    outputPoint = regexp( helpval, 'Output:' );
    [beg, en] = regexp( helpval, '[a-zA-Z0-9]+ = \([a-zA-Z0-9]+\)', 'start', 'end' );
    matches2 = size( beg );
    outputIndex = 1;
    for j = 1:matches2( 2 )
        if beg(j) < outputPoint
            outputIndex = outputIndex + 1;
        end
    end
    
    % set the inputs
    y = cell( outputIndex-1, 2 );
    for j = 1:outputIndex-1
        % the input name
        f = helpval( beg(j):en(j) );
        [bname, ename ] = regexp( f, '[a-zA-Z0-9]+ =', 'start', 'end' );
        name = f(bname(1):ename(1)-2);
        
        % the input type
        [btype, etype ] = regexp( f, '\([a-zA-Z0-9]+\)', 'start', 'end' );
        type = f(btype(1)+1:etype(1)-1);
        y( j, 1 ) = cellstr( name );
        y( j, 2 ) = cellstr( type );
    end
    functionMeta( i, 3 ) = {y};
       
    % set the outputs
    z = cell( matches2(2) + 1 - outputIndex, 1 );
    for j = 1:(matches2(2) + 1 - outputIndex)
        % the output name
        f = helpval( beg(j):en(j) );
        [bname, ename ] = regexp( f, '[a-zA-Z0-9]+ =', 'start', 'end' );
        name = f(bname(1):ename(1)-2);
        
        % the output type
        [btype, etype ] = regexp( f, '\([a-zA-Z0-9]+\)', 'start', 'end' );
        type = f(btype(1)+1:etype(1)-1);
        z( j, 1 ) = cellstr( name );
        z( j, 2 ) = cellstr( type );
    end
    functionMeta( i, 4 ) = {z};
end
x = functionMeta;

s = size( functionMeta );
numFunctions = s(1);
windowHeight = 20 + 40 * (numFunctions );
window = figure( 'Visible', 'off', 'Position', [100, 500, 300, windowHeight],...
    'MenuBar', 'none',...
    'Toolbar', 'none');
for i = 0:(numFunctions-1)
    control = uicontrol( 'Style', 'pushbutton',...
        'String', char( functionMeta( i+1, 1 ) ),...
        'Position', [ 10, windowHeight - 40 - (i*40), 280, 30 ],...
        'Callback', {@functionButtonCallback, i+1, functionMeta});
end
set( window, 'Visible', 'on' );
end

function functionButtonCallback( source, eventData, id, metadata )
    char( metadata( id, 1 ) )
    renderFunction( id, metadata )
end

function renderFunction( id, metadata )
%

    % determine the height of the window
    inputArgs = metadata( id, 3 );
    outputArgs = metadata( id, 4);
    nInputArgs = size( inputArgs{1} );
    nInputArgs = nInputArgs( 1 )
    nOutputArgs = size( outputArgs{1} );
    nOutputArgs = nOutputArgs( 1 )
    
    inputHeight = 20 + 40 * ( nInputArgs );
    outputHeight = 20 + 40 * ( nOutputArgs );
    
    windowheight = max( inputHeight, outputHeight );
    
    window = figure( 'Visible', 'off', 'Position', [100, 500, 740, windowheight], ...
        'MenuBar', 'none', ...
        'Toolbar', 'none' );
    
    % lay out the fields
    for i = 1:nInputArgs
        contol = uicontrol( 'Style', 'text',...
            'String', char( inputArgs{1}( i, 1 ) ),...
            'Position', [ 10, windowheight - (i*40), 150, 30 ] );
        control = uicontrol( 'Style', 'text', ...
            'String', char( inputArgs{1}( i, 2 ) ), ...
            'Position', [ 170, windowheight - (i*40), 90, 30 ] );
        control = uicontrol( 'Style', 'edit', ...
            'Position', [ 270, windowheight - (i*40), 90, 30 ],...
            'Callback', {@testCallback, i, metadata} );
    end
    for i = 1:nOutputArgs
        contol = uicontrol( 'Style', 'text',...
            'String', char( outputArgs{1}( i, 1 ) ),...
            'Position', [ 380, windowheight - (i*40), 150, 30 ] );
        control = uicontrol( 'Style', 'text', ...
            'String', char( outputArgs{1}( i, 2 ) ), ...
            'Position', [ 540, windowheight - (i*40), 90, 30 ] );
        control = uicontrol( 'Style', 'edit', ...
            'Position', [ 640, windowheight - (i*40), 90, 30 ] );
    end
    set( window, 'Visible', 'on' );
end

function testCallback( source, eventData, id, metadata )
    get( source, 'String' )
end
