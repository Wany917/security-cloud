import Link from 'next/link';

export default function HomePage() {
  return (
    <main className="flex flex-1 flex-col items-center justify-center px-6 text-center">
      <span className="mb-3 rounded-full border px-3 py-1 text-xs text-fd-muted-foreground">
        ESGI · Cloud Security &amp; IAM
      </span>
      <h1 className="mb-4 max-w-3xl text-4xl font-bold tracking-tight">
        Durcir une infrastructure AWS en Zero Trust, avec Terraform
      </h1>
      <p className="mb-8 max-w-2xl text-fd-muted-foreground">
        Du challenge offensif « kungfu » (SSRF, vol de credentials IMDS, secrets en clair)
        à une landing zone durcie de bout en bout : secrets chiffrés, réseau segmenté,
        journalisation et alerting, IAM au moindre privilège. Le tout en Infrastructure as
        Code, testé par une vraie CI/CD.
      </p>
      <div className="flex gap-3">
        <Link
          href="/docs"
          className="rounded-lg bg-fd-primary px-5 py-2.5 font-medium text-fd-primary-foreground"
        >
          Lire la documentation
        </Link>
        <Link
          href="https://github.com/Wany917/security-cloud"
          className="rounded-lg border px-5 py-2.5 font-medium"
        >
          Code source
        </Link>
      </div>
    </main>
  );
}
