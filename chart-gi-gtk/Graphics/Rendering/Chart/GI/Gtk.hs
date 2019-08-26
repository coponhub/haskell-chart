-----------------------------------------------------------------------------
-- |
-- Module      :  Graphics.Rendering.Chart.Gtk
-- Copyright   :  (c) Tim Docker 2006
-- License     :  BSD-style (see chart/COPYRIGHT)
{-# LANGUAGE OverloadedStrings, OverloadedLabels #-}

module Graphics.Rendering.Chart.GI.Gtk (
    renderableToWindow,
    toWindow,
    createRenderableWindow,
    liftIO
    -- updateCanvas
    ) where

import Data.GI.Base
import qualified Data.GI.Gtk as Gtk
import qualified GI.Gdk as Gdk
import GI.Cairo.Render (liftIO, Render)

--import Graphics.Rendering.Chart
import Graphics.Rendering.Chart.Renderable
--import Graphics.Rendering.Chart.Geometry
import Graphics.Rendering.Chart.Drawing
import Graphics.Rendering.Chart.Backend.GI.Cairo
import Graphics.Rendering.Chart.State(EC, execEC)

import Data.List (isPrefixOf)
import Data.IORef
import Data.Default.Class

import Control.Monad(unless)
import System.IO.Unsafe(unsafePerformIO)
import GI.Cairo.Render.Connector


-- Yuck. But we really want the convenience function
-- renderableToWindow as to be callable without requiring
-- initGUI to be called first. But newer versions of
-- gtk insist that initGUI is only called once
guiInitVar :: IORef Bool
{-# NOINLINE guiInitVar #-}
guiInitVar = unsafePerformIO (newIORef False)

initGuiOnce :: IO ()
initGuiOnce = do
    v <- readIORef guiInitVar
    unless v $ do
        Gtk.init Nothing
        writeIORef guiInitVar True

-- | Display a renderable in a gtk window.
--
-- Note that this is a convenience function that initialises GTK on
-- its first call, but not subsequent calls. Hence it's
-- unlikely to be compatible with other code using gtk. In
-- that case use createRenderableWindow.
renderableToWindow :: Renderable a -> Int -> Int -> IO ()
renderableToWindow chart windowWidth windowHeight = do
    initGuiOnce
    window <- createRenderableWindow chart windowWidth windowHeight
    -- press any key to exit the loop
    on window #keyPressEvent $ \_ -> do
                     Gtk.widgetDestroy window
                     return True
    on window #destroy $ Gtk.mainQuit
    #showAll window
    Gtk.main

-- | Generate a new GTK window from the state content of
-- an EC computation. The state may have any type that is
-- an instance of `ToRenderable`
toWindow :: (Default r, ToRenderable r) =>Int -> Int -> EC r () -> IO ()
toWindow windowWidth windowHeight ec = renderableToWindow r windowWidth windowHeight where
                       r = toRenderable (execEC ec)

-- | Create a new GTK window displaying a renderable.
createRenderableWindow :: Renderable a -> Int -> Int -> IO Gtk.Window
createRenderableWindow chart windowWidth windowHeight = do
    window <- new Gtk.Window [ #defaultWidth := (fromIntegral windowWidth)
                             , #defaultHeight := (fromIntegral windowHeight)
                             ]
    Gtk.widgetSetAppPaintable window True

    canvas <- Gtk.drawingAreaNew
    Gtk.containerAdd window canvas

    Gtk.onWidgetDraw canvas $ \context -> do
      renderWithContext (drawCanvasHandler canvas chart) context
      return True

    return window

drawCanvasHandler :: Gtk.DrawingArea -> Renderable a -> Render ()
drawCanvasHandler canvas chart = do
  mwin <- Gtk.widgetGetWindow canvas
  case mwin of
    Nothing -> return ()
    Just win -> do
      width  <- liftIO $ Gtk.widgetGetAllocatedWidth canvas
      height <- liftIO $ Gtk.widgetGetAllocatedHeight canvas
      let sz   = (fromIntegral width, fromIntegral height)
      runBackend (defaultEnv bitmapAlignmentFns) (render chart sz)
      return ()

{-
updateCanvas :: Renderable a -> Gtk.DrawingArea  -> IO Bool
updateCanvas chart canvas = do
    mwin <- Gtk.widgetGetWindow canvas
    case mwin of
      Nothing -> return False
      Just win -> do
        width  <- liftIO $ Gtk.widgetGetAllocatedWidth canvas
        height <- liftIO $ Gtk.widgetGetAllocatedHeight canvas
        let rect = Gtk.Rectangle 0 0 width height
        let sz   = (fromIntegral width, fromIntegral height)
        Gtk.drawWindowBeginPaintRect win rect
        Gtk.renderWithDrawWindow win
          $ runBackend (defaultEnv bitmapAlignmentFns) (render chart sz)
        Gtk.drawWindowEndPaint win
        return True
 -}
