library(igraph)
library(ggmap)
library(maps)


## change working directory if needed
SEA=c("Brunei","Cambodia","East Timor","Indonesia","Laos","Malaysia","Myanmar","Philippines","Singapore","Thailand","Vietnam")
load("country matrix_at least 3 trips.RData") # load mat.country1
mat=mat.country1 

# gcode.output1=geocode(colnames(mat),output="more")#source="google"
# geocodeQueryCheck()
# geocode.res=cbind(raw.country=colnames(mat),gcode.output1)
# save(geocode.res,file="country lat_long Geocoding.RData")
load("country lat_long Geocoding.RData")

of.interest=(rownames(mat) %in% SEA)
mat=mat[c(which(of.interest),which(!of.interest)),c(which(of.interest),which(!of.interest))]
of.interest=(rownames(mat) %in% SEA)
mat[,which(!of.interest)]=0

g=graph.adjacency(mat,mode="directed",weighted=T,diag=FALSE)
g$layout=layout.fruchterman.reingold
plot.igraph(g)
bad.vs=V(g)[degree(g)<1] #identify those vertices part of less than three edges
g=delete.vertices(g,bad.vs)
plot.igraph(g)
of.interest=(V(g)$name %in% SEA)


# match coordinates locations with network vertices
poss=match(V(g)$name, geocode.res$raw.country)
V(g)$long=geocode.res$lon[poss]
V(g)$lat=geocode.res$lat[poss]

# create the layout matrix
latex=matrix(c(V(g)$long,V(g)$lat),ncol=2)
g$layout=latex

cols=c("black","red")[(of.interest+1)]
V(g)$color=1
V(g)$size=1
V(g)$label=NA
# V(g)$label.color=rgb(0,0,0,0.5)
# V(g)$label.cex=0.8
# V(g)$label.dist=1
# V(g)$label.degree=pi
V(g)$frame.color=NA
E(g)$arrow.size=0.001
E(g)$width=1
E(g)$curved=-0.25

pal=colorRampPalette(c("yellow","orange","brown"))
colors=pal(101)
E(g)$color=colors[round(log(E(g)$weight)/max(log(E(g)$weight))*100)+1]


pdf("world map.pdf",width=12,height=8)
#layout(matrix(c(1,1,2,2),ncol=2),widths=c(5,1))
par(mar=c(1,1,1,1))
# plot background map
map("world",fill=TRUE,col="grey",bg="gray100",border="lightgrey")
# plot network graph
plot(g,add=T,rescale=FALSE)
points(V(g)$long,V(g)$lat,pch=19,col=cols)

# add colorbar legend
par(new=TRUE)
par(xpd=TRUE)
# plot region
plot(c(-180,180),c(-90,90),type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='')
lut=colors
scale = (length(lut)-1)/360
ticks=round(log(c(1,10,50,100,200,max(E(g)$weight)))/max(log(E(g)$weight))*100)+1
labels=c(1,10,50,100,200,max(E(g)$weight))
# add axis and value labels
axis(1, (ticks-1)/scale-180,labels,las=1)
# add rectangle filled with color
for (i in 1:(length(lut)-1)) {
  y = (i-1)/scale -180
  rect(y,-98,y+1/scale,-95,col=lut[i], border=NA)
}
text(-180,-90,"Number of trips",pos=4,cex=1.25)
dev.off()



############### SEA map #####################
load("mat.country2.RData")
load("country lat_long Geocoding.RData")
mat=mat.country2

of.interest=(rownames(mat) %in% SEA)
mat[,which(!of.interest)]=0

g=graph.adjacency(mat,mode="directed",weighted=T,diag=FALSE)
g$layout=layout.fruchterman.reingold
plot.igraph(g)
bad.vs=V(g)[degree(g)<1] #identify those vertices part of less than three edges
g=delete.vertices(g,bad.vs)
plot.igraph(g)
of.interest=(V(g)$name %in% SEA)

# match coordinates locations with network vertices
poss=match(V(g)$name, geocode.res$raw.country)
V(g)$long=geocode.res$lon[poss]
V(g)$lat=geocode.res$lat[poss]
summary(cbind(V(g)$long,V(g)$lat))


# V(g)$long[12]=105;V(g)$lat[12]=24 # Asia
# 
# V(g)$long[13]=90;V(g)$lat[13]=26 # Europe
# V(g)$long[13]=105;V(g)$lat[13]=26 # Oceania

sea.long=116.6072
sea.lat=8.719768
#"Asia\\SEA", "Europe", "Oceania", "North America", "Africa","South America"
alphas=c(0.9,0.3,0.7,0.18,0.32,0.2)
#temp=geocode(c("Asia",V(g)$name[13:17]),source="google")
for(i in 12:17){
  alpha=alphas[i-11]
  V(g)$long[i]=alpha*temp$lon[i-11]+(1-alpha)*sea.long
  V(g)$lat[i]=alpha*temp$lat[i-11]+(1-alpha)*sea.lat
}
cbind(V(g)$long,V(g)$lat)
V(g)$long[12]=110
V(g)$long[14]=118
V(g)$lat[15]=14
# create the layout matrix
latex=matrix(c(V(g)$long,V(g)$lat),ncol=2)
g$layout=latex

cols=c("black","red")[(of.interest+1)]
V(g)$color=1
V(g)$size=1
V(g)$label=V(g)$name
V(g)$label.color=rgb(0,0,0,0.8)
V(g)$label.cex=1.5
# V(g)$label.dist=1
# V(g)$label.degree=pi
V(g)$frame.color=NA
E(g)$arrow.size=0.05
E(g)$width=2
E(g)$curved=0

pal=colorRampPalette(c("yellow","orange","brown"))
colors=pal(101)
E(g)$color=colors[round(log(E(g)$weight)/max(log(E(g)$weight))*100)+1]


pdf("SEA map.pdf",width=12,height=8)
par(mar=c(1,1,1,1))
# plot background map
xlim=c(min(V(g)$long),max(V(g)$long))#+30
ylim=c(min(V(g)$lat),max(V(g)$lat))
country.col=topo.colors(11)[c(1,4,2,5:11,5)]
map("world",region=SEA,fill=TRUE,col="grey",bg="gray100",border="lightgrey",xlim=xlim,ylim=ylim)
for(i in c(1:2,4:8,10:11)){ #"East Timor" and "Singapore" cannot be recognized
  map("world",region=SEA[i],fill=TRUE,col=country.col[i],bg="gray100",border="lightgrey",add=TRUE)
}
par(xpd=TRUE)
#points(V(g)$long[1:11],V(g)$lat[1:11],pch=19,col=1)
text(V(g)$long[1:11],V(g)$lat[1:11],SEA,col=V(g)$label.color,cex=1.5)
################
# plot background map
xlim=c(min(V(g)$long),max(V(g)$long))
ylim=c(min(V(g)$lat),max(V(g)$lat))
map("world",region=SEA,fill=TRUE,col="grey",bg="gray100",border="lightgrey",xlim=xlim,ylim=ylim)
for(i in c(1:2,4:8,10:11)){ #"East Timor" and "Singapore" cannot be recognized
  map("world",region=SEA[i],fill=TRUE,col=country.col[i],bg="gray100",border="lightgrey",add=TRUE)
}
# plot network graph
plot(g,add=T,rescale=FALSE)
points(V(g)$long,V(g)$lat,pch=19,col=cols)

# add colorbar legend
par(new=TRUE)
par(xpd=TRUE)
# plot region
xmin=77
xmax=100
ymin=-13
ymax=31
plot(c(xmin,xmax+20),c(ymin,ymax),type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='')
lut=colors
scale = (length(lut)-1)/(xmax-xmin)
ticks=round(log(c(1,10,50,100,200,max(E(g)$weight)))/max(log(E(g)$weight))*100)+1
labels=c(1,10,50,100,200,max(E(g)$weight))
# add axis and value labels
axis(1, (ticks-1)/scale+xmin,labels,las=1)
# add rectangle filled with color
for (i in 1:(length(lut)-1)) {
  y = (i-1)/scale +xmin
  rect(y,ymin-2,y+1/scale,ymin-1.5,col=lut[i], border=NA)
}
text(xmin,ymin-0.75,"Number of trips",pos=4,cex=1.25)
dev.off()
