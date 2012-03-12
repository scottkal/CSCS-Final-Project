breed [ circle ]
breed [ resident ]

patches-own [ cluster value utility block decay place urban-decay? blight ]
resident-own [ class residents new-resident ]

globals [ radius_of_circle selx sely counter counter2 counter3 blight-count available? ]

;;------------------------------------------SETUP
to setup
    ca
    set radius_of_circle 15
    setup-patches
    locate-residents   
    associate-residents
    set-default-shape circle "box"

end


;;-------------------------------------------CREATE NEIGHBORHOODS
to setup-patches  
    ask patches
        [  
        set pcolor random 5 
        set cluster nobody
        ]
    repeat 50
        [ 
        ask patches
           [ 
           set pcolor [pcolor] of one-of neighbors4 
           ] 
        ]

;;--------------------------------------------CREATE CITY HOUSING STOCK  
    ask patches 
        [
        if (distancexy 0 0) < radius_of_circle
           [
           set value pcolor 
           set place 1
           ]
        ]
;;--------------------------------------------CREATE COUNTRYSIDE
    ask patches
       [
         if (distancexy 0 0) > radius_of_circle
         [ set pcolor 57 
           set place 2
           set value 0
           ] 
       ]

end

;;---------------------------------------------CLUSTER NEIGHBORHOODS
to find-clusters
    loop 
       [
         let seed one-of patches with [cluster = nobody]
         ask seed
            [ 
            set cluster self
            grow-cluster 
            ]
       ]
end

to grow-cluster  
    ask neighbors4 with [(cluster = nobody) and
    (pcolor = [pcolor] of myself)]
       [ 
          set cluster [cluster] of myself
          grow-cluster 
       ]
end

;;----------------------------------------------CREATE RESIDENTS

to locate-residents
    ask patches
      [  
      if (distancexy 0 0) < radius_of_circle
        [sprout-resident 1] 
    ask resident
      [ set class value 
      ]   
    ]
end

;;-----------------------------------------------CLASSIFY RESIDENTS

to associate-residents
   ask resident
      [
       if class = 0
          [ set color red ]
      ]      
   ask resident
      [    
       if class = 1
          [ set color orange ]
      ]
   ask resident
      [    
       if class = 2 
          [ set color yellow ]
      ]
   ask resident
      [    
       if class = 3
          [ set color green ]
      ]
   ask resident
      [    
       if class = 4
          [ set color blue ]
      ]
   ask resident
      [    
       if class = 5
          [ set color sky ]
      ]
end

;;----------------------------------------------- TO GO

to go
set counter 0     
set counter2 0
set counter3 0
set blight-count 0
    ask resident  ;;----------------------------- WEALTHY ASSESS NEIGHBORS, POOR EVALUATE NEIGHBORHOODS
        [    
          ask one-of resident
             [
               if class = 5   
                  [
                    set block (sum [value] of neighbors / 8)
                    if block < sensitivity * value [flee]
                    set counter ( counter + 1 )
                   ]
                if class = 4   
                    [
                     set block (sum [value] of neighbors / 8)
                     if block < sensitivity * value [flee]
                     set counter ( counter + 1 )
                    ]      
                 if class = 3
                    [
                     set block (sum [value] of neighbors / 8)
                     if block < sensitivity * value [flee]
                     set counter ( counter + 1 )
                    ]
                 if class = 2
                     [ move 
                       ;set counter2 ( counter2 + 1 )
                       ]
                 if class = 1   
                    [ 
                     if urban-decay? > 0  
                       [ move ] 
                    ;set counter2 ( counter2 + 1 )
                    ]                    ]
                 if class = 0   
                     [
                     if urban-decay? > 0  
                       [ move ] 
                     ;set counter2 ( counter2 + 1 )
                    ]                    
            ]                    
  

ask patches with [ place = decay ] ;;---------------------------------- UNINHABITED CITY PATCHES DETERIORATE
   [ 
  
              if value > 0
              [ set value [value] of self - ( pace_of_deterioration ) ]  
              
              if value < 0 [ set value 0 ]
              
              if pcolor > 0
              [ set pcolor [pcolor] of self - ( pace_of_deterioration )] 
              
              if pcolor > 8 [ set pcolor 0 ]
            
                  
            ]        
       
     
   

ask patches ;;----------------------------------- SUBURBAN DEVELOPMENT IMPROVES VALUE 
  [
    if place = 2 
    [
      if any? turtles-here
         [
           ask neighbors
           [
           if value < 6
           [
           set value [ value ] of self + .1  
           ] 
           if value > 6 [ set value 6 ]
           if pcolor < 6
           [
           set pcolor [ pcolor ] of self + .1
           ]
           if pcolor > 6
           [
           set pcolor 6 
           ]
         ]
    ]
  ]
  ]


ask patches  ;;----------------------------------- SET DECAY
  [ 
    if place = 1
      [
        if not any? turtles-here
           [ 
             set place decay
             set available? TRUE   
                ]
           ]
  ]
;ask patches ;;----------------------------------- DETERMINE CITY AVAILABILITY
 ;  [ 
  ;   if count  patches with [ place ] = decay ] > 0
   ;    [ new-residents ]
   
   ;]
ask patches    ;;----------------------------------- SET URBAN DECAY COUNT
  [ 
    if count patches with [ place = decay ] > 0
       [set urban-decay? 1] 
     ;[
     ;if value < 1 
      ;    [ set urban-decay? 1 ]
     ;if value > 1     
      ;    [ set urban-decay? 0]
     ;]
  ]

ask patches with [ place = decay ]
  [ if any? turtles-here
      [ 
        set value [value] of self + 2
        set pcolor [pcolor] of self + 2
        ask neighbors4
           [set value [value] of self + 1
            set pcolor [pcolor] of self + 1]
        set place 1
        set blight FALSE
      ]
  ]

ask patches with [ place = decay ]
  [
    if value < 1 
      [
        set blight-count (blight-count + 1)
        set blight TRUE
      ]
  ]
grow-population
do-plots
end

to flee   ;;------------------------------------ FLEEING RESIDENTS ASSESSMENT PROCEDURE
if counter >= 10 [stop]
let xlist 0 
let canx 0
let ylist 0 
let cany 0 
let util-list 0   
        repeat 100
        [
        ask one-of patches with [ place = 2 ]
            [ 
            set canx [pxcor] of patch-at 0 0 
            set cany [pycor] of patch-at 0 0
            ]
        if ( ( count turtles-at canx cany ) = 0 ) 
            [            
            set xlist ( sentence xlist canx )
            set ylist ( sentence ylist cany ) 
            set util-list ( sentence util-list
                    (sum [value] of neighbors / 8))
            ]
        ]   
     set selx item ( position ( max util-list ) util-list ) xlist
     set sely item ( position ( max util-list ) util-list ) ylist
     setxy selx sely
     set utility item ( position ( max util-list ) util-list ) util-list
     ask patch-here [ set pcolor [class] of myself 
                      set value pcolor           ] 
     ask neighbors [ set pcolor [class] of myself 
                      set value pcolor           ] 
       
end     


to move  ;;----------------------------------- INNER CITY RESIDENTS MOVING PROCEDURE

if urban-decay? = 1
[
  
  if counter >= 10  [stop]
  let xlist 0
  let canx 0
  let ylist 0
  let cany 0
  let util-list 0   

 repeat 200
      [
        ask one-of patches with [ place = decay ] 
            [ 
            set canx [pxcor] of patch-at 0 0 
            set cany [pycor] of patch-at 0 0
            ]
        ;if not any? turtles-at canx cany ]  
        if ( ( count turtles-at canx cany ) = 0 ) 
            [ 
            set xlist ( sentence xlist canx )
            set ylist ( sentence ylist cany ) 
            set util-list ( sentence util-list
                    (sum [value] of neighbors / 8))
 ]
        ]   
      
     set selx item ( position ( max util-list ) util-list ) xlist
     set sely item ( position ( max util-list ) util-list ) ylist
     setxy selx sely
     set utility item ( position ( max util-list ) util-list ) util-list
     ask patches in-radius 1 [ set pcolor [class] of myself 
                      set value pcolor           ] 
     set counter2 ( counter2 + 1 )
     
] 
end


to grow-population ;;------------------------------ RANDOM PATCHES SPROUT NEW RESIDENTS 
if ( grow_population = TRUE )
[
  if counter3 >= 5 [stop]
    repeat 50
    [
    ask one-of patches 
     [
       if place = decay
       [
              sprout-resident 1 
              set counter3 ( counter3 + 1 )
              ]   
       ]
     ]
]
end

to do-plots ;;----------------------------------- GRAPH SUBURBAN DWELLERS AND DECAY
   set-current-plot "Suburban dwellers"
   plot count resident with 
     [ ( distancexy 0 0 ) >= radius_of_circle ] 
   
   set-current-plot "urban-decay"
   plot blight-count
   
end



