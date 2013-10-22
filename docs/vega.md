# Vega

Everything is explicit


Axis are separate from scales definitions

    { type: "y", scale: , attr: DATASPEC }
    for example:
        { offset: 10 }
        { offset: {scale: ord, value: "blah" }
        
    
How to do coord xforms? none.  special `arc` mark.

data can be defined as

    { "data": }
    # explicitly apply scale to field value
    { "scale": name of scale, "field": domain value } 
    { "group": previously grouped-on attribute }
    { "field": "data[.field]" }  # data is a record in input table
    { "value": explicit value }
    { "function": ?? }   # no
    constant
    
Marks can be faceter (creates and allocates a facet that is container for sub-marks)

    marks: {  
        "type": "group",
       "from": [data],
       "scales",
       "marks": { ... }
    }

