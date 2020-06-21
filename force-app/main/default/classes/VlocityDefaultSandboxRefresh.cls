global class VlocityDefaultSandboxRefresh implements SandboxPostCopy 
{
    global void runApexClass(SandboxContext context) 
    {
        vlocity_cmt.CorePostInstallClass.runDev2ProdInserts();
    }
}