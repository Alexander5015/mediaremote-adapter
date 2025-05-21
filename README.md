# mediaremote-adapter

Get now playing information with the MediaRemote framework
on macOS 15.4 and newer.

This works by using system binary &ndash; `/usr/bin/perl` in this case &ndash;
which is entitled to use the MediaRemote framework
and dynamically loading a custom helper framework
which prints real-time updates to the standard output.

## Usage

```
$ git clone https://github.com/ungive/mediaremote-adapter.git
$ cd mediaremote-adapter
$ mkdir build && cd build
$ cmake ..
$ cmake --build .
$ cd ..
$ FRAMEWORK_PATH=$(realpath ./build/MediaRemoteAdapter.framework)
$ /usr/bin/perl ./scripts/MediaRemoteAdapter.pl "$FRAMEWORK_PATH"
```

The output of this command is characterised by the following rules:

- The script runs indefinitely until the process is terminated with a signal
- Each line printed to stdout contains a single JSON dictionary with the following keys:
    - type (string): Always "data". There are no other types at the moment
    - diff (boolean): Whether to update the previous non-diff payload. When this value is true, only the keys for updated values are set in the payload. Other keys should retain the value of the data payloads before this one
    - payload (dictionary): The now playing metadata. The keys should be self-explanatory. For details check the convertNowPlayingInformation function in [src/MediaRemoteAdapter.m](./src/MediaRemoteAdapter.m). All available keys are always set to either a value or null when diff is false or no keys are set at all when no media player is reporting now playing information. There are may be missing keys when diff is true, but at least one keys is always set. For a list of all keys check [src/MediaRemoteAdapterKeys.m](./src/MediaRemoteAdapterKeys.m)
- The script exits with an exit code other than 0 when a fatal error occured, e.g. when the MediaRemote framework could not be loaded. This may be used to stop any retries of executing this command again
- The script terminates gracefully when a SIGTERM signal is sent to the process. This signal should be used to cancel the observation of changes to now playing items
- It is recommended to use Objective-C's NSJSONSerialization for deserialization of JSON output, since that is used to serialize the underlying NSDictionary. Escape sequences like `\/` may not be parsed properly otherwise. Likewise, NSData's initWithBase64EncodedString method may be used to parse the artwork data
- You must always pass the full path of the adapter framework to the script as the first argument
- Each line printed to stderr is an error message

Here is an example of what the output may look like:

```
{"type":"data","diff":false,"payload":{"artist":"Sara Rikas","timestampEpochMicros":1747256447190675,"title":"Cigarety","bundleIdentifier":"com.tidal.desktop","elapsedTimeMicros":0,"playing":false,"album":"Ja, Sára","artworkMimeType":"image\/jpeg","durationMicros":281346077,"artworkDataBase64":null}}
{"type":"data","diff":true,"payload":{"artworkDataBase64":"\/9j\/4AAQSkZJRgABAQAAS..."}}
{"type":"data","diff":true,"payload":{"timestampEpochMicros":1747260249656367,"elapsedTimeMicros":75372614}}
{"type":"data","diff":true,"payload":{"timestampEpochMicros":1747260311282554,"elapsedTimeMicros":0,"durationMicros":281000000}}
{"type":"data","diff":true,"payload":{"timestampEpochMicros":1747260312118660,"playing":true,"durationMicros":281346077}}
{"type":"data","diff":true,"payload":{"timestampEpochMicros":1747260324723482,"elapsedTimeMicros":12772000,"playing":false}}
```

The artwork data is shortened for brevity.
