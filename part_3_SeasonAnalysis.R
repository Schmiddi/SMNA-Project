#################################################
##
##    Function definitions
##
##################################################

#######
##
##  Returns the number of days in the month of the given date
##
#######
numberOfDays <- function(date) {
  m = format(date, format="%m")
  
  while (format(date, format="%m") == m) {
    date = date + 1
  }
  
  return(strtoi(format(date-1,"%d")))
}

#######
##
##    Get months within the date range
##  
##    parameters:
##        - start date (Format: YYYY-MM-DD)
##        - end date (Format: YYYY-MM-DD)
##    return  vector with 12 elements, and the values according to the number of visits (max 1 per year) but if someone is
##              travelling for more than a year there might be a 2 or 3 instead 1 or 0
######
getMonths <- function(startDate, endDate){
  result = vector(mode='integer', length = 12)
  # Same year
  if(format(startDate,"%Y")==format(endDate,"%Y")){
    # Same month
    if(format(startDate,"%m")==format(endDate,"%m")){
      result[as.integer(format(endDate,"%m"))] = 1
    }
    # Multiple months
    else{
      # 7 days in the first month (maxDays-day-1) because the day you post is included (24. until 30. == 7 days)
      if((numberOfDays(startDate)-as.integer(format(startDate,"%d"))+1) >= 7){
        result[as.integer(format(startDate,"%m"))] = 1   
      }
      
      # 7 days in the second month (at least the 7th of the month)
      if(as.integer(format(endDate,"%d")) >= 7){
        result[as.integer(format(endDate,"%m"))] = 1   
      }
      
      # Two month
      if(as.integer(format(endDate,"%m"))-as.integer(format(startDate,"%m")) ==  1){
        # If the duration in both month was below 7 days, then mark the one with more days, 
        # if both are the same, select the first month
        
        if(sum(result) == 0){
          daysStart = (numberOfDays(startDate)-as.integer(format(startDate,"%d"))+1)
          daysEnd = as.integer(format(endDate,"%d"))
          
          if(daysStart > daysEnd){
            result[as.integer(format(startDate,"%m"))] = 1   
          }else if(daysStart < daysEnd){
            result[as.integer(format(endDate,"%m"))] = 1   
          }else{
            result[as.integer(format(startDate,"%m"))] = 1   
          }
        }
      }
      # More than two month
      else {
        # Add all month between the first and the last month
        i = as.integer(format(startDate,"%m")) + 1
        while(i < as.integer(format(endDate,"%m"))){
          result[i] = 1   
          i = i+1;
        }
      }
    }
  }else {
    # Multiple years (could also be December-January)
    
    # 7 days in the first month (maxDays-day-1) because the day you post is included (24. until 30. == 7 days)
    if((numberOfDays(startDate)-as.integer(format(startDate,"%d"))+1) >= 7){
      result[as.integer(format(startDate,"%m"))] = 1   
    }
    endDate
    # 7 days in the second month (at least the 7th of the month)
    if(as.integer(format(endDate,"%d")) >= 7){
      result[as.integer(format(endDate,"%m"))] = 1   
    }
    
    result = result + getMonthsBetween(startDate, endDate)
    
  }
  return(result)
}

######
##
##    Get all the month between two dates not including the month from the dates
##
######
getMonthsBetween = function(startDate, endDate){
  result = vector(mode='integer', length = 12)
  
  startYear = as.integer(format(startDate,"%Y"))
  # Exclude the first month
  startMonth = as.integer(format(startDate,"%m"))+1
  if(startMonth > 12){
    startMonth = 1
    startYear = startYear + 1
  }
  
  endYear = as.integer(format(endDate,"%Y"))
  endMonth = as.integer(format(endDate,"%m"))
  
  while(startYear < endYear || (startYear==endYear && startMonth<endMonth )){
    
    result[startMonth] = result[startMonth] + 1
    
    startMonth = startMonth + 1
    if(startMonth > 12){
      startMonth = 1
      startYear = startYear + 1
    }
  }
  return (result)
}


##################################################
##
##    Load data
##
#################################################
load("data/travelpod corrected.RData")
SEA=c("Brunei","Cambodia","East Timor","Indonesia","Laos","Malaysia","Myanmar","Philippines","Singapore","Thailand","Vietnam")
months=c("January","February","March", "April", "May", "June", "July", "August", "September", "October", "November", "December")


##################################################
##
##    Extract the traveldate for each country
##
##################################################
# Extract the moth of visiting
# Procedure:  For each blog, order the entries by date.
#             Ignore consecutive entries about the same country. 
#             Get the time frame of the visit. 
#             Count a month if:
#               1. The visit was only in this month (e.g. for the last entry in a blog where we don't now the duration)
#               2. The visit was over multiple month and:
#                   a. The visit was over this full month
#                   b. The visit was at least on 7 days of this month.
#                   c. The visit was longest in this month (but in neither of the month for 7 days)
#               ~ if the visit was over years the month will be counted for each year once.


# Which are the most popular seasons for a trip to SEA in general (country stay duration.csv) (NEW DATA) [Dennis]
# Are there different seasons for different countries in SEA? (country stay duration.csv) (NEW DATA) [Dennis]

# Matrix for counting the month of visiting a SEA country (row=months, coloumns=country)
mat.season.sea = matrix(0,nrow=length(months),ncol=length(SEA),dimnames=list(months,SEA))
# Get all countries where at the authors are from
countries = unique(dat$author_country)
# Matrix for counting in which month people from which country visiting a SEA country (row=months, coloumns=country)
mat.season.origin.country = matrix(0,nrow=length(months),ncol=length(countries),dimnames=list(months,countries))


# Get the list of blogIds
blogids = unique(dat$blogId)
for(bi in blogids){
  # Get all blog entry of this blog bi
  dat.sub=dat[dat$blogId==bi,]
  # Order the blog entries by date
  dat.sub=dat.sub[order(dat.sub$entry_date),]
  
  # Set the dates for the country of origin
  startDate = dat.sub[1,]$entry_date
  endDate = dat.sub[nrow(dat.sub),]$entry_date
  visit.months = getMonths(dat.sub[1,]$entry_date, dat.sub[nrow(dat.sub),]$entry_date)
  mat.season.origin.country[,which(countries==dat.sub[1,]$author_country)] = mat.season.origin.country[,which(countries==dat.sub[1,]$author_country)] + visit.months

    
  # Set the dates for the destination country in SEA

  ## If we have only one entry
  if(nrow(dat.sub)==1){
    if(dat.sub[1,]$entry_country %in% SEA){
      # Get country (col)
      country = which(SEA==dat.sub[1,]$entry_country)
      # Get month (row)
      visit.month = strtoi(format(dat.sub[1,]$entry_date,"%m"))
      # Increase month-country element by 1
      mat.season.sea[visit.month,country] = mat.season.sea[visit.month,country] + 1
    }
  }else{
    maxIndex = nrow(dat.sub)
    start = 1
    end = 2
    # If there is only one entry, it will be skipped, otherwise it will iterate over all but the last entry
    while(start < maxIndex){
      while(dat.sub[start,]$entry_country == dat.sub[end,]$entry_country){
        end = end + 1
        if(end>maxIndex){
          end = maxIndex
          break
        }
      }
      if(dat.sub[start,]$entry_country %in% SEA){
        dat.sub[end,]$entry_date
        visit.months = getMonths(dat.sub[start,]$entry_date, dat.sub[end,]$entry_date)
        country = which(SEA==dat.sub[start,]$entry_country)
        mat.season.sea[,country] = mat.season.sea[,country] + visit.months
      }
      start = end
      end = end + 1
    }
    # If the last entry is from a different country than the second last, increase it month-country element
    if(dat.sub[maxIndex,]$entry_country != dat.sub[maxIndex-1,]$entry_country){
      # If it is a SEA country
      if(dat.sub[maxIndex,]$entry_country %in% SEA){
        # Get country (col)
        country = which(SEA==dat.sub[maxIndex,]$entry_country)
        # Get month (row)
        visit.month = strtoi(format(dat.sub[maxIndex,]$entry_date,"%m"))
        # Increase month-country element by 1
        mat.season.sea[visit.month,country] = mat.season.sea[visit.month,country] + 1
      }
    }
  }
}

save(mat.season.origin.country,file="data/seasons_origin_country.RData")
save(mat.season.sea,file="data/seasons_destination_SEA_country.RData")
