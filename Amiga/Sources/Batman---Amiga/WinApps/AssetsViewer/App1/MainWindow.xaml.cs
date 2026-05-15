using App1.Domain;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Imaging;
using Microsoft.UI.Xaml.Navigation;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.Graphics.Imaging;
using Windows.Storage.Pickers;
using WinRT;
//using System.Runtime.InteropServices;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.


namespace App1
{

    [ComImport]
    [Guid("5B0D3235-4DBA-4D44-865E-8F1D0E4FD04D")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    unsafe interface IMemoryBufferByteAccess
    {
        void GetBuffer(out byte* buffer, out uint capacity);
    }



    /// <summary>
    /// An empty window that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainWindow : Window
    {

        GameAsset _gameAsset = null;
        CancellationTokenSource _cancellationTokenSource = new CancellationTokenSource();
        int startIndex = 0;
        SoftwareBitmap softwareBitmap = new SoftwareBitmap(BitmapPixelFormat.Bgra8, 128, 512, BitmapAlphaMode.Premultiplied);


        public MainWindow()
        {
            this.InitializeComponent();
        }


        private async void menuFileOpen_Click(object sender, RoutedEventArgs e)
        {
            var hwnd = WinRT.Interop.WindowNative.GetWindowHandle(this);
            var picker = new FileOpenPicker();
            WinRT.Interop.InitializeWithWindow.Initialize(picker, hwnd);
            picker.FileTypeFilter.Add("*");
            picker.ViewMode = PickerViewMode.List;
            picker.SuggestedStartLocation = PickerLocationId.DocumentsLibrary;

            Windows.Storage.StorageFile file = await picker.PickSingleFileAsync();
            if (file != null)
            {
                using (var stream = await file.OpenStreamForReadAsync())
                {
                    _gameAsset = await GameAsset.CreateGameAsset(stream, _cancellationTokenSource.Token);
                }
            }


            //unsafe
            //{

            //    using (BitmapBuffer buffer = softwareBitmap.LockBuffer(BitmapBufferAccessMode.Write))
            //    {
            //        using (var reference = buffer.CreateReference())
            //        {
            //            byte* dataInBytes;
            //            uint capacity;
            //            var memoryBuffer = reference.As<IMemoryBufferByteAccess>();
            //            memoryBuffer.GetBuffer(out dataInBytes, out capacity);

            //            // Fill-in the BGRA plane
            //            BitmapPlaneDescription bufferLayout = buffer.GetPlaneDescription(0);
            //            for (int i = 0; i < bufferLayout.Height; i++)
            //            {
            //                for (int j = 0; j < bufferLayout.Width; j++)
            //                {
            //                    byte value = (byte)((float)j / bufferLayout.Width * 255);
            //                    dataInBytes[bufferLayout.StartIndex + bufferLayout.Stride * i + 4 * j + 0] = value;
            //                    dataInBytes[bufferLayout.StartIndex + bufferLayout.Stride * i + 4 * j + 1] = value;
            //                    dataInBytes[bufferLayout.StartIndex + bufferLayout.Stride * i + 4 * j + 2] = value;
            //                    dataInBytes[bufferLayout.StartIndex + bufferLayout.Stride * i + 4 * j + 3] = (byte)255;
            //                }
            //            }
            //        }
            //    }

            //}


            //if (softwareBitmap.BitmapPixelFormat != BitmapPixelFormat.Bgra8 ||
            //    softwareBitmap.BitmapAlphaMode == BitmapAlphaMode.Straight)
            //{
            //    softwareBitmap = SoftwareBitmap.Convert(softwareBitmap, BitmapPixelFormat.Bgra8, BitmapAlphaMode.Premultiplied);
            //}

            //var source = new SoftwareBitmapSource();
            //await source.SetBitmapAsync(softwareBitmap);

            //// Set the source of the Image control
            //bitmapImage.Source = source;

        }



        private void menuFileExit_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }



        private async void btnPlus_Click(object sender, RoutedEventArgs e)
        {
            startIndex += 4;

            unsafe
            {

                using (BitmapBuffer buffer = softwareBitmap.LockBuffer(BitmapBufferAccessMode.Write))
                {
                    using (var reference = buffer.CreateReference())
                    {
                        byte* dataInBytes;
                        uint capacity;
                        var memoryBuffer = reference.As<IMemoryBufferByteAccess>();
                        memoryBuffer.GetBuffer(out dataInBytes, out capacity);
                        BitmapPlaneDescription bufferLayout = buffer.GetPlaneDescription(0);

                        for (int i = 0; i < 32; i += 4)
                        {

                            var gfxByte1 = _gameAsset.MemoryBuffer.Span[startIndex + i + 0];
                            var gfxByte2 = _gameAsset.MemoryBuffer.Span[startIndex + i + 1];
                            var gfxByte3 = _gameAsset.MemoryBuffer.Span[startIndex + i + 2];
                            var gfxByte4 = _gameAsset.MemoryBuffer.Span[startIndex + i + 3];

                            for (int a = 7; a > 0; a--)
                            {
                                var byteoffset = (a * -1) + 7;
                                var gfxLine = i / 4;
                                //var pixelColour = GetBit(a, gfxByte1);
                                var pixelColour = (byte)0;
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * gfxLine + 4) + byteoffset + 0] = pixelColour;
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * gfxLine + 4) + byteoffset + 1] = pixelColour;
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * gfxLine + 4) + byteoffset + 2] = pixelColour;
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * gfxLine + 4) + byteoffset + 3] = 255;
                            }

                            for (int a = 7; a > 0; a--)
                            {
                                var byteoffset = (a * -1) + 7;
                                var gfxLine = i / 4;
                                //var pixelColour = GetBit(a, gfxByte1);
                                var pixelColour = (byte)0;
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * gfxLine) + byteoffset + 4] = pixelColour;
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * gfxLine) + byteoffset + 5] = pixelColour;
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * gfxLine) + byteoffset + 6] = pixelColour;
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * gfxLine) + byteoffset + 7] = 255;
                            }


                        }


                    }   // using

                }

            }       // unsafe

            if (softwareBitmap.BitmapPixelFormat != BitmapPixelFormat.Bgra8 ||
                softwareBitmap.BitmapAlphaMode == BitmapAlphaMode.Straight)
            {
                softwareBitmap = SoftwareBitmap.Convert(softwareBitmap, BitmapPixelFormat.Bgra8, BitmapAlphaMode.Premultiplied);
            }

            var source = new SoftwareBitmapSource();
            await source.SetBitmapAsync(softwareBitmap);

            // Set the source of the Image control
            bitmapImage.Source = source;
            

        }



        private async void btnMinus_Click(object sender, RoutedEventArgs e)
        {
            startIndex -= 4;
            if (startIndex < 0)
            {
                startIndex = 0;
            }

            unsafe
            {

                using (BitmapBuffer buffer = softwareBitmap.LockBuffer(BitmapBufferAccessMode.Write))
                {
                    using (var reference = buffer.CreateReference())
                    {
                        byte* dataInBytes;
                        uint capacity;
                        var memoryBuffer = reference.As<IMemoryBufferByteAccess>();
                        memoryBuffer.GetBuffer(out dataInBytes, out capacity);
                        BitmapPlaneDescription bufferLayout = buffer.GetPlaneDescription(0);

                        for (int i = startIndex; i < startIndex + 16; i += 4)
                        {

                            var gfxByte1 = _gameAsset.MemoryBuffer.Span[i + 0];
                            var gfxByte2 = _gameAsset.MemoryBuffer.Span[i + 1];
                            var gfxByte3 = _gameAsset.MemoryBuffer.Span[i + 2];
                            var gfxByte4 = _gameAsset.MemoryBuffer.Span[i + 3];

                            for (int a = 7; a > 0; a--)
                            {
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * (i / 4)) + ((a * -1) + 7) + 0] = GetBit(8, gfxByte1);
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * (i / 4)) + ((a * -1) + 7) + 1] = GetBit(8, gfxByte1);
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * (i / 4)) + ((a * -1) + 7) + 2] = GetBit(8, gfxByte1);
                                dataInBytes[bufferLayout.StartIndex + (bufferLayout.Stride * (i / 4)) + ((a * -1) + 7) + 3] = 255;
                            }



                        }


                    }   // using

                }

            }       // unsafe

            if (softwareBitmap.BitmapPixelFormat != BitmapPixelFormat.Bgra8 ||
                softwareBitmap.BitmapAlphaMode == BitmapAlphaMode.Straight)
            {
                softwareBitmap = SoftwareBitmap.Convert(softwareBitmap, BitmapPixelFormat.Bgra8, BitmapAlphaMode.Premultiplied);
            }

            var source = new SoftwareBitmapSource();
            await source.SetBitmapAsync(softwareBitmap);

            // Set the source of the Image control
            bitmapImage.Source = source;

        }



        private byte GetBit(int bitIndex, byte value)
        {
            var isSet = ((2 ^ bitIndex) & value);
            if (isSet > 0)
            {
                return 0;
            }
            return 255;
        }


    }



}
