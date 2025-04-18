;+
PRO CCG_EX_LEGEND2,dev=dev,ccg=ccg
   ;
   ;-------------------------------------- procedure description
   ;
   ;provides examples of the use of
   ;   (1)   ccg_opendev
   ;   (2)    ccg_slegend
   ;   (3)   ccg_tlegend
   ;   (4)   ccg_llegend
   ;   (5)   ccg_labid
   ;   (6)    ccg_closedev
   ;
   ;
   CCG_OPENDEV, dev=dev,pen=pen
   ;
   PLOT,   [0,0],[1,1],TITLE='LEGEND EXAMPLE'
   ;
   ;intialization of some legend vectors
   ;
   chartext = [ 'this', 'is', 'a', 'test' ]
   symstyle=[ -1, 2, 5, -1 ]
   linestyle=[ 1, -1, -1, -1 ]
   color = [2,3,4,5]
   charsize = [1,2,3,4]
   charthick=4

   CCG_LEGEND, x=.2,y=.8, $
               chartext=chartext, $
               charsize=charsize, $
               charthick=charthick,$
               symstyle=symstyle, $
               linestyle=linestyle, $
               /frame, $
               color=color
   ;
   ;intialization of some legend vectors
   ;
   chartext = [ 'this', 'is', 'a', 'test' ]
   linestyle=[ 1, 0, 2, 3 ]
   color = [2,3,4]
   charsize = [2]
   charthick=4

   CCG_LEGEND, x=.4,y=.6, $
               chartext=chartext, $
               charsize=charsize, $
               charthick=charthick,$
               linestyle=linestyle, $
               color=color
   ;
   ;intialization of some legend vectors
   ;
   titletext='once in a blue moon'
   titlecolor= 7
   chartext = [ 'this', 'is', 'a', 'test' ]
   linestyle=[ 1, 0, 2, 3 ]
   color = [2,3,4,6]
   charsize = [2]
   charthick=4

   CCG_LEGEND, x=.6,y=.4, $
               titletext=titletext,$
               titlecolor=titlecolor,$
               chartext=chartext, $
               charsize=charsize, $
               charthick=charthick,$
               color=color
   ;
   ;intialization of some legend vectors
   ;
   titletext='once in a blue moon'
   titlecolor= 67
   chartext = [ 'this', 'is', 'a', 'test' ]
   symstyle=[ 1, 2, 3, 10 ]
   symsize=[ 1, 1, 1, 1 ]
   symfill=[ 1, 1, 0, 1 ]
   color = [2,3,4,6]
   charsize = [2]
   charthick=4

   CCG_LEGEND, x=.2,y=.4, $
               titletext=titletext,$
               titlecolor=titlecolor,$
               chartext=chartext, $
               ;charsize=charsize, $
               ;charthick=charthick,$
               symstyle=symstyle, $
               symsize=symsize, $
               symfill=symfill, $
               /frame, $
               color=color

               
    
   ;------------------------------------------------ ccg label
    
   IF NOT KEYWORD_SET(ccg) THEN CCG_LABID,full=1
    
   ;----------------------------------------------- close up shop 
    
   CCG_CLOSEDEV,   dev=dev
   END
   ;-
