// OCI Control Center API Monitor
// 用法：填入 ~/.oci/config 後，執行 `node scripts/occ-monitor.mjs`
import { ConfigFileAuthenticationDetailsProvider } from "oci-common";
import { ControlCenterClient, ListCapacityRequestsRequest } from "oci-control-center";

const provider = new ConfigFileAuthenticationDetailsProvider();
const client = new ControlCenterClient({ authenticationDetailsProvider: provider });

const region = process.env.OCI_REGION || "ap-singapore-1";
client.region = region;

async function main() {
    try {
        const req = new ListCapacityRequestsRequest({ compartmentId: process.env.OCI_TENANCY });
        const res = await client.listCapacityRequests(req);
        console.log(`[OCC] ${region} capacity requests: ${res.capacityRequests?.length ?? 0}`);
        for (const cr of res.capacityRequests ?? []) {
            console.log(` - ${cr.displayName}: ${cr.lifecycleState}`);
        }
    } catch (err) {
        console.error("[OCC] ERROR:", err.message);
        process.exit(1);
    }
}

main();
