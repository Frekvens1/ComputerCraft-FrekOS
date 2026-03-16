import './App.css'

import {Button} from '@/components/ui/button'
import {Card, CardFooter, CardHeader, CardTitle} from '@/components/ui/card.tsx';

function App() {

    return (
        <main className='h-screen md:h-dvh flex flex-col'>
            <div className='h-full flex flex-col gap-2 items-center justify-center'>
                <Card size='sm' className='mx-auto w-full max-w-sm'>
                    <CardHeader>
                        <CardTitle className='text-center'>Hello ComputerCraft!</CardTitle>
                    </CardHeader>
                    <CardFooter>
                        <Button variant='outline' size='sm' className='w-full'>
                            Action
                        </Button>
                    </CardFooter>
                </Card>
            </div>
        </main>
    )
}

export default App
