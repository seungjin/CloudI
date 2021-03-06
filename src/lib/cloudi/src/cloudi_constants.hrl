
% interval at which asynchronous messages are checked
-define(RECV_ASYNC_INTERVAL, 500). % milliseconds

% interval at which asynchronous messages are sent
-define(SEND_ASYNC_INTERVAL, 500). % milliseconds

% interval at which synchronous messages are sent
-define(SEND_SYNC_INTERVAL, 500). % milliseconds

% interval at which multicast asynchronous messages are sent
-define(MCAST_ASYNC_INTERVAL, 500). % milliseconds

% interval at which synchronous forwarded messages are sent
-define(FORWARD_SYNC_INTERVAL, 500). % milliseconds

% interval at which asynchronous forwarded messages are sent
-define(FORWARD_ASYNC_INTERVAL, 500). % milliseconds

% maximum possible time for a process death to remove process group membership
% when using a slow refresh (fast refresh is immediate).  slow refresh is
% used when a process is mainly communicating with long-lived processes
% (and fast refresh is used when mainly communicating with
%  short-lived processes).
-define(DEST_REFRESH_SLOW, 300000). % milliseconds

% after startup, assign the initial process group membership
-define(DEST_REFRESH_FIRST,  500). % milliseconds

% blocking operations must decrement the timeout to make sure timeouts
% have time to unravel all synchronous calls
-define(TIMEOUT_DELTA, 100). % milliseconds

% maximum wait time before a reconnect is attempted with a node
-define(NODE_RECONNECT, 60000). % milliseconds

% periodic connection checks to determine if the udp connection is still active
% must be a short time since this impacts MaxR and MaxT.  However, this time
% becomes a hard maximum (minus a delta for overhead) for a task time target
% used in a service/job (i.e., the maximum amount of time spent not responding
% to incoming API calls).
-define(KEEPALIVE_UDP, 5000). % milliseconds

