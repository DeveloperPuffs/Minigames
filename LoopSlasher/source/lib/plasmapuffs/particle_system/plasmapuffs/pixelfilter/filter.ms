
// javascript

// Create the SVG element
const svgNS = "http://www.w3.org/2000/svg";
const svg = document.createElementNS(svgNS, "svg");
const filter = document.createElementNS(svgNS, "filter");
filter.setAttribute("id", "alias");

// This will make the alpha either transparent or the target alpha
const feComponentTransfer = document.createElementNS(svgNS, "feComponentTransfer");
const feFuncA = document.createElementNS(svgNS, "feFuncA");
feFuncA.setAttribute("type", "discrete");

// A function used to update the alpha value dynamically
global.setAliasAlpha = function(alpha) {
  alpha = Math.min(Math.max(alpha, 0), 1);
  feFuncA.setAttribute("tableValues", `0, 0, ${alpha}`);
}

// Transfer the filter component into the SVG element
feComponentTransfer.appendChild(feFuncA);
filter.appendChild(feComponentTransfer);
svg.appendChild(filter);
  
// Add the SVG to the DOM
document.body.appendChild(svg);
global.setAliasAlpha(1);
