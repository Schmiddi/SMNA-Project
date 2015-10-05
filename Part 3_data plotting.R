#tools to plot the data
#Run command install.packages("igraph") if you have not done so (Run Rstudio as admin)

library(igraph)

plotName <- file.choose()

#import the csv file:
dat=read.csv(plotName,                     # read .csv file from prompt
             header=TRUE,
             row.names=1,
             check.names=FALSE)

m=as.matrix(dat)

net=graph.adjacency(m,mode="directed",          #used to make the directed graph
                    weighted=TRUE,
                    diag=FALSE
                    )

bad.vs<-V(net)[degree(net)<15]                  #filter by degree
net<-delete.vertices(net,                       #exclude them from the graph
                    bad.vs)

par(mai=c(0,0,1,0))                             #this specifies the size of the margins

V(net)$size<-degree(net)/6

plot.igraph(net,                                #plots our graph
            main=basename(plotName),                      #change title according to which csv is loaded
            vertex.label=V(net)$name,
            layout=layout.fruchterman.reingold, 
            
            vertex.label.color="black",
            vertex.label.dist=.35,			        #puts the name labels slightly off the dots
            vertex.label.color='red',		        #the color of the name labels
            vertex.label.font=1.5,			        #the font of the name labels
            vertex.label.cex=1,			            #specifies the size of the font of the labels
            
            edge.color="black",
            edge.width=E(net)$weight/15,        #more weight are thicker by a factor
            edge.arrow.size=.25,
            edge.curved=TRUE                    #Makes it curvy
            )
