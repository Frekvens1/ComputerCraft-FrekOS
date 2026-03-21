import {SectionCards} from '@/components/section-cards.tsx';
import {ChartAreaInteractive} from '@/components/chart-area-interactive.tsx';

export function DashboardPage() {
    return (
        <>
            <SectionCards/>
            <div className='px-4 lg:px-6'>
                <ChartAreaInteractive/>
            </div>
        </>
    )
}
