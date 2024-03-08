window.addEventListener('DOMContentLoaded', function() {

    var cy = window.cy = cytoscape({
        container: document.getElementById('cy'),

        // boxSelectionEnabled: false,
        // autounselectify: true,

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
                { data: { id: 'somehting-with-a-big-name____2222' } , style: { 'width': '200px'} },
                { data: { id: 'n1' } },
                { data: { id: 'n2' } },
                { data: { id: 'n3', size: '100' } },
                { data: { id: 'n4___move_me...' } },
                { data: { id: 'another.fantastic.function.name' } },
                { data: { id: 'understandable.function.name' } },
                { data: { id: 'n7' } },
                { data: { id: 'n8' } },
                { data: { id: 'n9' } },
                { data: { id: 'n10' } },
                { data: { id: 'n11' } },
                { data: { id: 'n12' } },
                { data: { id: 'n13' } },
                { data: { id: 'n14' } },
                { data: { id: 'n15' } },
                { data: { id: 'n16' } }
            ],
            edges: [
                { data: { source: 'somehting-with-a-big-name____2222', target: 'n1' } },
                { data: { source: 'n1', target: 'n2' } },
                { data: { source: 'n1', target: 'n3' } },
                { data: { source: 'n4___move_me...', target: 'another.fantastic.function.name' } },
                { data: { source: 'n4___move_me...', target: 'understandable.function.name' } },
                { data: { source: 'understandable.function.name', target: 'n7' } },
                { data: { source: 'understandable.function.name', target: 'n8' } },
                { data: { source: 'n8', target: 'n9' } },
                { data: { source: 'n8', target: 'n10' } },
                { data: { source: 'n11', target: 'n12' } },
                { data: { source: 'n12', target: 'n13' } },
                { data: { source: 'n13', target: 'n14' } },
                { data: { source: 'n13', target: 'n15' } },


                { data: { source: 'n3', target: 'n4___move_me...' } },
                { data: { source: 'understandable.function.name', target: 'n3' } },
                { data: { source: 'n4___move_me...', target: 'n13' } },
            ]
        }

    });

    // var makeDiv = function(text){
    //     var div = document.createElement('div');

    //     div.classList.add('popper-div');
    //     div.innerHTML = text;
    //     document.body.appendChild( div );

    //     return div;
    // };

    // var a = cy.getElementById('n7');
    // // var a = cy.getElementById('somehting-with-a-big-name____2222');

    // var popperA = a.popper({
    //     content: function(){ return makeDiv('Sticky position div'); }
    // });

    // var updateA = function(){
    //     popperA.update();
    // };

    // a.on('position', updateA);
    // cy.on('pan zoom resize', updateA);

    // cy.on('tap', 'node', function (evt) {
    //     console.log(evt.target.id())
    // });


    cy.nodes().lock();

    cy.$('#n4___move_me...').unlock();


    cy.on('tap', 'node', function() {
        console.log(this.id())
    });

});
