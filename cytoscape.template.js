window.addEventListener('DOMContentLoaded', function() {

    var cy = window.cy = cytoscape({
        container: document.getElementById('cy'),

        layout: {
            name: 'dagre',
            fit: true,
            padding: 16,
            avoidOverlap: true,
            nodeDimensionsIncludeLabels: true,
        },

        style: [
            {
                selector: 'node',
                style: {
                    'content': 'data(id)',  // pode ser: data(label)
                    'text-valign': 'center',
                    'text-halign': 'center',
                    'font-size': '0.8em',
                    'shape': 'rectangle',
                    'height': '20px',
                    'color': '#000',
                    'background-color': '#eeeef9',
                    'border-width': 1,
                    'border-color': '#99F',
                    "z-index": "1",
                }
            },

            {
                selector: 'edge',
                style: {
                    'width': 2,
                    'target-arrow-shape': 'triangle',
                    'line-color': '#9dbaea',
                    'target-arrow-color': '#9dbaea',
                    'curve-style': 'bezier',
                }
            }
        ],

        elements: {
            nodes: [
~a
            ],
            edges: [
~a
            ]
        }

    });

    // cy.nodes().lock();

    cy.on('tap', 'node', function() {
        console.log(this.id())
    });

});
