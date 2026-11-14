// main.js
// Utility function to copy text to clipboard (not used but kept for reference)
function copyToClipboard(text) {
    Qt.application.clipboard.setText(text);
    console.log("Copied to clipboard:", text);
}

// Utility to decode HTML entities
function decodeHtmlEntities(text) {
    if (!text) return "";

    var namedEntities = {
        "zwnj": "\u200C",
        "zwj": "\u200D",
        "rlm": "\u200F",
        "lrm": "\u200E",
        "laquo": "\u00AB",
        "raquo": "\u00BB",
        "quot": '"',
        "apos": "'",
        "lt": "<",
        "gt": ">",
        "nbsp": " ",
        "hellip": "…",
        "ndash": "–",
        "mdash": "—",
        "amp": "&"
    };

    var fromCodePoint = (typeof String.fromCodePoint === "function")
        ? String.fromCodePoint
        : String.fromCharCode;

    return text
        // Decode hexadecimal numeric entities (e.g. &#xAB;, &#xBB;, &#x200C;)
        .replace(/&#[xX]([0-9a-fA-F]+);/g, function(match, hex) {
            var code = parseInt(hex, 16);
            try {
                return (!isNaN(code) && code > 0) ? fromCodePoint(code) : match;
            } catch (e) {
                return match;
            }
        })
        // Decode decimal numeric entities (e.g. &#171;, &#8204;)
        .replace(/&#([0-9]+);/g, function(match, dec) {
            var code = parseInt(dec, 10);
            try {
                return (!isNaN(code) && code > 0) ? fromCodePoint(code) : match;
            } catch (e) {
                return match;
            }
        })
        // Decode named entities (e.g. &laquo;, &raquo;, &zwnj;, &amp;)
        .replace(/&([a-zA-Z]+);/g, function(match, name) {
            var lower = name.toLowerCase();
            return namedEntities.hasOwnProperty(lower) ? namedEntities[lower] : match;
        })
        // Remove control characters (but keep ZWNJ)
        .replace(/[\n\r\t]/g, "");
}

// Process the JavaScript response from ganjoor.net
function processHtml(response) {
    console.log("Raw response:", response);

    if (!response || !response.includes("ganjoor-m1")) {
        console.log("Invalid response: 'ganjoor-m1' not found, using fallback");
        return showFallbackPoem();
    }

    var lines = response.split('\n');
    var abyat = [];
    var poetName = '';
    var poemLink = '';

    for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim();

        // Extract mesras (ganjoor-m1 and ganjoor-m2)
        if (line.includes('ganjoor-m1') || line.includes('ganjoor-m2')) {
            var contentStart = line.indexOf('>') + 1;
            var contentEnd = line.lastIndexOf('<');
            if (contentStart !== -1 && contentEnd !== -1 && contentStart < contentEnd) {
                var rawVerse = line.substring(contentStart, contentEnd).trim();
                var verse = decodeHtmlEntities(rawVerse);
                if (verse) {
                    abyat.push(verse);
                    console.log("Found verse:", verse);
                }
            }
        }

        // Extract poet name and link (ganjoor-poet)
        if (line.includes('ganjoor-poet')) {
            var hrefStart = line.indexOf('<a href="') + 9;
            var hrefEnd = line.indexOf('"', hrefStart);
            if (hrefStart !== -1 && hrefEnd !== -1) {
                poemLink = line.substring(hrefStart, hrefEnd);
                console.log("Found poem link:", poemLink);
            }

            var nameStart = line.indexOf('>', hrefStart) + 1;
            var nameEnd = line.indexOf('<', nameStart);
            if (nameStart !== -1 && nameEnd !== -1 && nameStart < nameEnd) {
                poetName = line.substring(nameStart, nameEnd).trim();
                poetName = decodeHtmlEntities(poetName); // Decode poet name as well
                console.log("Found poet name:", poetName);
            }
        }
    }

    // Format the mesras
    var mesras = [];
    if (abyat.length === 2) {
        mesras = [abyat[0], abyat[1], "", ""];
        console.log("Only one beyt fetched, padding with empty mesras");
    } else if (abyat.length === 4) {
        mesras = [abyat[0], abyat[1], abyat[2], abyat[3]];
        console.log("Two beyts fetched, displaying all four mesras");
    } else {
        console.log("Unexpected verse count:", abyat.length);
        return showFallbackPoem();
    }

    if (!poetName || !poemLink) {
        console.log("Poet name or link missing, using fallback");
        return showFallbackPoem();
    }

    return {
        mesras: mesras,
        poet: poetName,
        link: poemLink
    };
}

// Show a random poem from history or a default message
function showFallbackPoem(history) {
    if (history && history.length > 0) {
        var randomIndex = Math.floor(Math.random() * history.length);
        var historyItem = history[randomIndex];
        console.log("Showing fallback poem from history at index:", randomIndex);
        return {
            mesras: historyItem.mesras,
            poet: historyItem.poet,
            link: historyItem.link
        };
    } else {
        console.log("No history available, showing error message");
        return {
            mesras: ["خطا در بارگذاری شعر", "", "", ""],
            poet: "ناشناس",
            link: ""
        };
    }
}

// Show previous poem
function showPreviousPoem(history) {
    if (history && history.length > 0) {
        var previousPoem = history[history.length - 1];
        console.log("Showing previous poem, history length before pop:", history.length);
        return {
            poem: {
                mesras: previousPoem.mesras,
                poet: previousPoem.poet,
                link: previousPoem.link
            },
            newHistory: history.slice(0, -1)
        };
    } else {
        console.log("No previous poems in history");
        return null;
    }
}

// Initialize history from configuration
function initializeHistory(storedHistory) {
    var history = [];
    for (var i = 0; i < storedHistory.length; i++) {
        try {
            var item = storedHistory[i];
            if (item.includes("||")) {
                var parts = item.split("||");
                var mesras = parts[0].split("\n").map(function(s) { return s.trim(); });
                while (mesras.length < 4) mesras.push("");
                history.push({
                    mesras: mesras,
                    poet: parts[1],
                    link: parts[2]
                });
            } else {
                history.push(JSON.parse(item));
            }
        } catch (e) {
            console.error("Failed to parse history item:", storedHistory[i], e);
        }
    }
    console.log("Initialized history, length:", history.length);
    return history;
}
