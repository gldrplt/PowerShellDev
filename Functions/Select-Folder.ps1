function Select-Folder {
    [CmdletBinding()]
    param(
        [string]$InitialDirectory = (Get-Location).Path,
        [string]$Title = "Select Folder"
    )

    if (-not ("NativeFolderDialog" -as [type])) {

        Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class NativeFolderDialog
{
    [ComImport]
    [Guid("d57c7288-d4ad-4768-be02-9d969532d960")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IFileOpenDialog
    {
        [PreserveSig] int Show(IntPtr parent);
        [PreserveSig] int SetFileTypes(uint cFileTypes, IntPtr rgFilterSpec);
        [PreserveSig] int SetFileTypeIndex(uint iFileType);
        [PreserveSig] int GetFileTypeIndex(out uint piFileType);
        [PreserveSig] int Advise(IntPtr pfde, out uint pdwCookie);
        [PreserveSig] int Unadvise(uint dwCookie);
        [PreserveSig] int SetOptions(uint fos);
        [PreserveSig] int GetOptions(out uint fos);
        [PreserveSig] int SetDefaultFolder(IShellItem psi);
        [PreserveSig] int SetFolder(IShellItem psi);
        [PreserveSig] int GetFolder(out IShellItem ppsi);
        [PreserveSig] int GetCurrentSelection(out IShellItem ppsi);
        [PreserveSig] int SetFileName(string pszName);
        [PreserveSig] int GetFileName(out string pszName);
        [PreserveSig] int SetTitle(string pszTitle);
        [PreserveSig] int SetOkButtonLabel(string pszText);
        [PreserveSig] int SetFileNameLabel(string pszLabel);
        [PreserveSig] int GetResult(out IShellItem ppsi);
        [PreserveSig] int AddPlace(IShellItem psi, uint fdap);
        [PreserveSig] int RemovePlace(IShellItem psi);
        [PreserveSig] int SetDefaultExtension(string pszDefaultExtension);
        [PreserveSig] int Close(int hr);
        [PreserveSig] int SetClientGuid(ref Guid guid);
        [PreserveSig] int ClearClientData();
        [PreserveSig] int SetFilter(IntPtr pFilter);
    }

    [ComImport]
    [Guid("43826d1e-e718-42ee-bc55-a1e261c37bfe")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IShellItem
    {
        [PreserveSig] int BindToHandler(
            IntPtr pbc,
            ref Guid bhid,
            ref Guid riid,
            out IntPtr ppv);

        [PreserveSig] int GetParent(out IShellItem ppsi);

        [PreserveSig] int GetDisplayName(
            uint sigdnName,
            out IntPtr ppszName);

        [PreserveSig] int GetAttributes(
            uint sfgaoMask,
            out uint psfgaoAttribs);

        [PreserveSig] int Compare(
            IShellItem psi,
            uint hint,
            out int piOrder);
    }

    private static class NativeMethods
    {
        [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
        public static extern int SHCreateItemFromParsingName(
            string pszPath,
            IntPtr pbc,
            ref Guid riid,
            out IShellItem ppv);
    }

    public static string SelectFolder(string initialDirectory, string title)
    {
        var clsid = new Guid(
            "DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7");

        var type = Type.GetTypeFromCLSID(clsid);
        var dialog = (IFileOpenDialog)Activator.CreateInstance(type);

        // FOS_PICKFOLDERS
        // FOS_FORCEFILESYSTEM
        const uint FOS_PICKFOLDERS = 0x00000020;
        const uint FOS_FORCEFILESYSTEM = 0x00000040;

        uint options;

        int hr = dialog.GetOptions(out options);

        if (hr != 0)
            Marshal.ThrowExceptionForHR(hr);

        options |= FOS_PICKFOLDERS | FOS_FORCEFILESYSTEM;

        hr = dialog.SetOptions(options);

        if (hr != 0)
            Marshal.ThrowExceptionForHR(hr);

        if (!String.IsNullOrEmpty(title))
            dialog.SetTitle(title);

        // Set initial folder
        if (!String.IsNullOrEmpty(initialDirectory) &&
            System.IO.Directory.Exists(initialDirectory))
        {
            Guid iidShellItem =
                new Guid("43826d1e-e718-42ee-bc55-a1e261c37bfe");

            IShellItem shellItem;

            hr = NativeMethods.SHCreateItemFromParsingName(
                initialDirectory,
                IntPtr.Zero,
                ref iidShellItem,
                out shellItem);

            if (hr == 0)
                dialog.SetFolder(shellItem);
        }

        // Show dialog
        hr = dialog.Show(IntPtr.Zero);

        // User cancelled
        if (hr != 0)
            return null;

        IShellItem result;

        hr = dialog.GetResult(out result);

        if (hr != 0)
            Marshal.ThrowExceptionForHR(hr);

        IntPtr pathPtr;

        // SIGDN_FILESYSPATH
        const uint SIGDN_FILESYSPATH = 0x80058000;

        hr = result.GetDisplayName(
            SIGDN_FILESYSPATH,
            out pathPtr);

        if (hr != 0)
            Marshal.ThrowExceptionForHR(hr);

        try
        {
            return Marshal.PtrToStringUni(pathPtr);
        }
        finally
        {
            Marshal.FreeCoTaskMem(pathPtr);
        }
    }
}
'@
    }

    $path = [NativeFolderDialog]::SelectFolder(
        $InitialDirectory,
        $Title
    )

    if ($null -ne $path) {
        return Get-Item -LiteralPath $path
    }
}